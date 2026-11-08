enum TrackerId { anilist, shikimori, mal }

enum TrackerMediaType { manga, anime }

enum TrackerStatus { planning, current, completed, paused, dropped, repeating }

class TrackerAccount {
  const TrackerAccount({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    required this.userId,
    required this.userName,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final int userId;
  final String userName;

  bool isExpired(DateTime now) {
    final DateTime? expiry = expiresAt;
    if (expiry == null) {
      return false;
    }
    return !now.isBefore(expiry.subtract(const Duration(minutes: 2)));
  }

  TrackerAccount copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    int? userId,
    String? userName,
  }) {
    return TrackerAccount(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
      'userId': userId,
      'userName': userName,
    };
  }

  static TrackerAccount? fromJson(Map<String, Object?> json) {
    final Object? token = json['accessToken'];
    final Object? userId = json['userId'];
    if (token is! String || token.isEmpty || userId is! int) {
      return null;
    }
    final Object? expiresAt = json['expiresAt'];
    final Object? refreshToken = json['refreshToken'];
    final Object? userName = json['userName'];
    return TrackerAccount(
      accessToken: token,
      refreshToken: refreshToken is String ? refreshToken : null,
      expiresAt: expiresAt is int
          ? DateTime.fromMillisecondsSinceEpoch(expiresAt)
          : null,
      userId: userId,
      userName: userName is String ? userName : '',
    );
  }
}

class TrackerSearchResult {
  const TrackerSearchResult({
    required this.remoteId,
    required this.title,
    this.cover,
    this.format,
    this.year,
    this.totalCount,
    this.malId,
  });

  final int remoteId;
  final String title;
  final String? cover;
  final String? format;
  final int? year;
  final int? totalCount;
  final int? malId;
}

class TrackerEntry {
  const TrackerEntry({
    required this.status,
    required this.progress,
    this.totalCount,
  });

  final TrackerStatus status;
  final int progress;
  final int? totalCount;
}

class TrackerLink {
  const TrackerLink({
    required this.concreteUid,
    required this.trackerId,
    required this.extensionUid,
    required this.mediaType,
    required this.remoteId,
    required this.remoteTitle,
    required this.status,
    required this.progress,
    this.totalCount,
    this.pendingProgress,
    this.syncedAt,
  });

  final String concreteUid;
  final TrackerId trackerId;
  final String extensionUid;
  final TrackerMediaType mediaType;
  final int remoteId;
  final String remoteTitle;
  final TrackerStatus status;
  final int progress;
  final int? totalCount;
  final int? pendingProgress;
  final DateTime? syncedAt;

  TrackerLink copyWith({
    TrackerStatus? status,
    int? progress,
    int? totalCount,
    int? Function()? pendingProgress,
    DateTime? syncedAt,
  }) {
    return TrackerLink(
      concreteUid: concreteUid,
      trackerId: trackerId,
      extensionUid: extensionUid,
      mediaType: mediaType,
      remoteId: remoteId,
      remoteTitle: remoteTitle,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalCount: totalCount ?? this.totalCount,
      pendingProgress:
          pendingProgress == null ? this.pendingProgress : pendingProgress(),
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

class TrackerAuthException implements Exception {
  const TrackerAuthException(this.message);

  final String message;

  @override
  String toString() => 'TrackerAuthException: $message';
}
