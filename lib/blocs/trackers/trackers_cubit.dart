import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';
import 'package:wakaranai/services/trackers/tracker_service.dart';
import 'package:wakaranai/services/trackers/tracker_sync_service.dart';

class TrackersState {
  const TrackersState({
    this.available = const <TrackerId>[],
    this.accounts = const <TrackerId, TrackerAccount>{},
    this.busy,
  });

  final List<TrackerId> available;
  final Map<TrackerId, TrackerAccount> accounts;
  final TrackerId? busy;

  bool get hasAccounts => accounts.isNotEmpty;

  List<TrackerId> get loggedIn => available
      .where((TrackerId id) => accounts.containsKey(id))
      .toList(growable: false);

  TrackersState copyWith({
    List<TrackerId>? available,
    Map<TrackerId, TrackerAccount>? accounts,
    TrackerId? Function()? busy,
  }) {
    return TrackersState(
      available: available ?? this.available,
      accounts: accounts ?? this.accounts,
      busy: busy == null ? this.busy : busy(),
    );
  }
}

class TrackersCubit extends Cubit<TrackersState> {
  TrackersCubit({required this.sync}) : super(const TrackersState());

  final TrackerSyncService sync;

  String nameOf(TrackerId id) => sync.services[id]?.name ?? id.name;

  Future<void> init() async {
    final List<TrackerId> available = sync.available
        .map((TrackerService service) => service.id)
        .toList(growable: false);
    final Map<TrackerId, TrackerAccount> accounts = await sync.loggedIn();
    if (isClosed) {
      return;
    }
    emit(state.copyWith(available: available, accounts: accounts));
    if (accounts.isNotEmpty) {
      try {
        await sync.retryPending();
      } catch (error) {
        logger.w('Retrying tracker updates failed: $error');
      }
    }
  }

  Future<bool> login(TrackerId id) async {
    emit(state.copyWith(busy: () => id));
    try {
      final TrackerAccount account = await sync.login(id);
      emit(state.copyWith(
        accounts: <TrackerId, TrackerAccount>{...state.accounts, id: account},
        busy: () => null,
      ));
      return true;
    } catch (error) {
      logger.w('Tracker login failed for ${id.name}: $error');
      emit(state.copyWith(busy: () => null));
      return false;
    }
  }

  Future<void> logout(TrackerId id) async {
    await sync.logout(id);
    final Map<TrackerId, TrackerAccount> accounts =
        Map<TrackerId, TrackerAccount>.of(state.accounts)..remove(id);
    emit(state.copyWith(accounts: accounts));
  }
}
