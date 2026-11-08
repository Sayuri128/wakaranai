import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wakaranai/main.dart';

const String kPictureInPictureChannel = 'wakaranai/pip';

enum PictureInPictureAction { togglePlayback, nextEpisode }

class PictureInPictureConfig extends Equatable {
  const PictureInPictureConfig({
    required this.autoEnter,
    required this.aspectWidth,
    required this.aspectHeight,
    required this.playing,
    required this.hasNext,
    required this.toggleTitle,
    required this.nextTitle,
  });

  final bool autoEnter;
  final int aspectWidth;
  final int aspectHeight;
  final bool playing;
  final bool hasNext;
  final String toggleTitle;
  final String nextTitle;

  Map<String, Object> toArguments() {
    return <String, Object>{
      'autoEnter': autoEnter,
      'aspectWidth': aspectWidth,
      'aspectHeight': aspectHeight,
      'playing': playing,
      'hasNext': hasNext,
      'toggleTitle': toggleTitle,
      'nextTitle': nextTitle,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    autoEnter,
    aspectWidth,
    aspectHeight,
    playing,
    hasNext,
    toggleTitle,
    nextTitle,
  ];
}

bool isUsableVideoSize(Size size) {
  return size.width > 0 && size.height > 0;
}

abstract class PictureInPicture {
  Future<bool> isSupported();

  Future<void> configure(PictureInPictureConfig config);

  Future<bool> enter();

  Future<void> disable();

  ValueListenable<bool> get inPictureInPicture;

  Stream<PictureInPictureAction> get actions;

  void dispose();
}

PictureInPicture createPictureInPicture() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return MethodChannelPictureInPicture();
  }
  return NoopPictureInPicture();
}

class MethodChannelPictureInPicture implements PictureInPicture {
  MethodChannelPictureInPicture({
    MethodChannel channel = const MethodChannel(kPictureInPictureChannel),
  }) : _channel = channel {
    _activeHandlerOwner = this;
    _channel.setMethodCallHandler(_handleCall);
  }

  static MethodChannelPictureInPicture? _activeHandlerOwner;

  final MethodChannel _channel;
  final ValueNotifier<bool> _inPictureInPicture = ValueNotifier<bool>(false);
  final StreamController<PictureInPictureAction> _actions =
      StreamController<PictureInPictureAction>.broadcast();

  @override
  ValueListenable<bool> get inPictureInPicture => _inPictureInPicture;

  @override
  Stream<PictureInPictureAction> get actions => _actions.stream;

  @override
  Future<bool> isSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } catch (error) {
      logger.w('Failed to check picture-in-picture support: $error');
      return false;
    }
  }

  @override
  Future<void> configure(PictureInPictureConfig config) async {
    try {
      await _channel.invokeMethod<void>('configure', config.toArguments());
    } catch (error) {
      logger.w('Failed to configure picture-in-picture: $error');
    }
  }

  @override
  Future<bool> enter() async {
    try {
      return await _channel.invokeMethod<bool>('enter') ?? false;
    } catch (error) {
      logger.w('Failed to enter picture-in-picture: $error');
      return false;
    }
  }

  @override
  Future<void> disable() async {
    try {
      await _channel.invokeMethod<void>('disable');
    } catch (error) {
      logger.w('Failed to disable picture-in-picture: $error');
    }
  }

  @override
  void dispose() {
    if (identical(_activeHandlerOwner, this)) {
      _activeHandlerOwner = null;
      _channel.setMethodCallHandler(null);
    }
    unawaited(_actions.close());
    _inPictureInPicture.dispose();
  }

  Future<void> _handleCall(MethodCall call) async {
    switch (call.method) {
      case 'pipModeChanged':
        _inPictureInPicture.value = call.arguments == true;
        return;
      case 'pipAction':
        _forwardAction(call.arguments);
        return;
    }
  }

  void _forwardAction(Object? name) {
    final PictureInPictureAction? action = _actionNamed(name);
    if (action == null || _actions.isClosed) {
      return;
    }
    _actions.add(action);
  }

  PictureInPictureAction? _actionNamed(Object? name) {
    switch (name) {
      case 'toggle':
        return PictureInPictureAction.togglePlayback;
      case 'next':
        return PictureInPictureAction.nextEpisode;
    }
    return null;
  }
}

class NoopPictureInPicture implements PictureInPicture {
  final ValueNotifier<bool> _inPictureInPicture = ValueNotifier<bool>(false);

  @override
  ValueListenable<bool> get inPictureInPicture => _inPictureInPicture;

  @override
  Stream<PictureInPictureAction> get actions =>
      const Stream<PictureInPictureAction>.empty();

  @override
  Future<bool> isSupported() async {
    return false;
  }

  @override
  Future<void> configure(PictureInPictureConfig config) async {}

  @override
  Future<bool> enter() async {
    return false;
  }

  @override
  Future<void> disable() async {}

  @override
  void dispose() {
    _inPictureInPicture.dispose();
  }
}
