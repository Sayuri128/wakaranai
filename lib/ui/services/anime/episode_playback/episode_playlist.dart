import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';

const String _numberPattern = r'(\d+(?:[.,]\d+)?)';
const String _episodeWords =
    r'(?:серія|серiя|серия|эпизод|епізод|episode|ep|эп|еп)';

final List<RegExp> _episodeNumberPatterns = <RegExp>[
  RegExp(
    '(?<!\\p{L})s\\d+\\s*[ex]\\s*$_numberPattern',
    caseSensitive: false,
    unicode: true,
  ),
  RegExp(
    '(?<!\\p{L})$_episodeWords\\s*\\.?\\s*(?:№|#)?\\s*$_numberPattern',
    caseSensitive: false,
    unicode: true,
  ),
  RegExp(
    '$_numberPattern\\s*(?:-?\\s*(?:я|й|th|st|nd|rd))?\\s*$_episodeWords(?!\\p{L})',
    caseSensitive: false,
    unicode: true,
  ),
  RegExp('(?:#|№)\\s*$_numberPattern', unicode: true),
  RegExp('$_numberPattern\\s*\$', unicode: true),
];

double? parseEpisodeNumber(String title) {
  final String trimmed = title.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  for (final RegExp pattern in _episodeNumberPatterns) {
    final RegExpMatch? match = pattern.firstMatch(trimmed);
    if (match == null) {
      continue;
    }
    final double? number = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (number != null) {
      return number;
    }
  }
  return null;
}

double? episodeNumberOf(AnimeVideo episode) {
  return episode.number ?? parseEpisodeNumber(episode.title);
}

class EpisodeOrderKey implements Comparable<EpisodeOrderKey> {
  const EpisodeOrderKey({required this.season, required this.number});

  final int season;
  final double number;

  @override
  int compareTo(EpisodeOrderKey other) {
    if (season != other.season) {
      return season.compareTo(other.season);
    }
    return number.compareTo(other.number);
  }

  bool operator >(EpisodeOrderKey other) => compareTo(other) > 0;

  bool operator <(EpisodeOrderKey other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) {
    return other is EpisodeOrderKey &&
        other.season == season &&
        other.number == number;
  }

  @override
  int get hashCode => Object.hash(season, number);
}

EpisodeOrderKey? episodeOrderKeyOf(AnimeVideo episode) {
  final double? number = episodeNumberOf(episode);
  if (number == null) {
    return null;
  }
  return EpisodeOrderKey(season: episode.season ?? 0, number: number);
}

class EpisodeGroupOrder {
  EpisodeGroupOrder(this.episodes)
      : keys = episodes.map(episodeOrderKeyOf).toList(growable: false) {
    descending = _detectDescending();
    numbered = _detectNumbered();
  }

  final List<AnimeVideo> episodes;
  final List<EpisodeOrderKey?> keys;
  late final bool descending;
  late final bool numbered;

  List<AnimeVideo> get ascending {
    if (descending) {
      return episodes.reversed.toList(growable: false);
    }
    return episodes;
  }

  int indexOf(AnimeVideo episode) {
    return episodes.indexWhere((AnimeVideo video) => video.uid == episode.uid);
  }

  int ascendingIndexOf(AnimeVideo episode) {
    final int index = indexOf(episode);
    if (index < 0 || !descending) {
      return index;
    }
    return episodes.length - 1 - index;
  }

  AnimeVideo? after(AnimeVideo episode) {
    final EpisodeOrderKey? currentKey = episodeOrderKeyOf(episode);
    if (numbered && currentKey != null) {
      return _closestNumbered(currentKey, upwards: true);
    }
    return _neighbour(episode, ascendingStep: 1);
  }

  AnimeVideo? before(AnimeVideo episode) {
    final EpisodeOrderKey? currentKey = episodeOrderKeyOf(episode);
    if (numbered && currentKey != null) {
      return _closestNumbered(currentKey, upwards: false);
    }
    return _neighbour(episode, ascendingStep: -1);
  }

  AnimeVideo? withKey(EpisodeOrderKey key) {
    for (int index = 0; index < episodes.length; index++) {
      if (keys[index] == key) {
        return episodes[index];
      }
    }
    return null;
  }

  AnimeVideo? _closestNumbered(
    EpisodeOrderKey currentKey, {
    required bool upwards,
  }) {
    AnimeVideo? best;
    EpisodeOrderKey? bestKey;
    for (int index = 0; index < episodes.length; index++) {
      final EpisodeOrderKey? key = keys[index];
      if (key == null) {
        continue;
      }
      final bool onRightSide = upwards ? key > currentKey : key < currentKey;
      if (!onRightSide) {
        continue;
      }
      if (bestKey == null || _isCloser(key, bestKey, upwards: upwards)) {
        best = episodes[index];
        bestKey = key;
      }
    }
    return best;
  }

  bool _isCloser(
    EpisodeOrderKey candidate,
    EpisodeOrderKey best, {
    required bool upwards,
  }) {
    if (upwards) {
      return candidate < best;
    }
    return candidate > best;
  }

  AnimeVideo? _neighbour(AnimeVideo episode, {required int ascendingStep}) {
    final int index = indexOf(episode);
    if (index < 0) {
      return null;
    }
    final int step = descending ? -ascendingStep : ascendingStep;
    final int target = index + step;
    if (target < 0 || target >= episodes.length) {
      return null;
    }
    return episodes[target];
  }

  bool _detectDescending() {
    int increasing = 0;
    int decreasing = 0;
    EpisodeOrderKey? previous;
    for (final EpisodeOrderKey? key in keys) {
      if (key == null) {
        continue;
      }
      if (previous != null) {
        if (key > previous) {
          increasing++;
        } else if (key < previous) {
          decreasing++;
        }
      }
      previous = key;
    }
    return decreasing > increasing;
  }

  bool _detectNumbered() {
    final Set<EpisodeOrderKey> seen = <EpisodeOrderKey>{};
    int count = 0;
    for (final EpisodeOrderKey? key in keys) {
      if (key == null) {
        continue;
      }
      if (!seen.add(key)) {
        return false;
      }
      count++;
    }
    return count >= 2;
  }
}

class EpisodePlaylist {
  EpisodePlaylist._({
    required this.groups,
    required this.groupIndex,
    required this.current,
    required List<EpisodeGroupOrder?> orders,
  }) : _orders = orders;

  factory EpisodePlaylist({
    required List<AnimeVideoGroup> groups,
    required int groupIndex,
    required AnimeVideo current,
  }) {
    final List<AnimeVideoGroup> snapshot = List<AnimeVideoGroup>.unmodifiable(
      groups.map(
        (AnimeVideoGroup group) => AnimeVideoGroup(
          title: group.title,
          elements: List<AnimeVideo>.unmodifiable(group.elements),
        ),
      ),
    );
    return EpisodePlaylist._(
      groups: snapshot,
      groupIndex: groupIndex,
      current: current,
      orders: List<EpisodeGroupOrder?>.filled(snapshot.length, null),
    );
  }

  factory EpisodePlaylist.single(AnimeVideo episode) {
    return EpisodePlaylist(
      groups: <AnimeVideoGroup>[
        AnimeVideoGroup(title: '', elements: <AnimeVideo>[episode]),
      ],
      groupIndex: 0,
      current: episode,
    );
  }

  final List<AnimeVideoGroup> groups;
  final int groupIndex;
  final AnimeVideo current;
  final List<EpisodeGroupOrder?> _orders;

  bool get hasGroup => groupIndex >= 0 && groupIndex < groups.length;

  AnimeVideoGroup? get group => hasGroup ? groups[groupIndex] : null;

  List<AnimeVideo> get episodes => group?.elements ?? const <AnimeVideo>[];

  bool get hasSeveralGroups => groups.length > 1;

  AnimeVideo? get next => _currentOrder?.after(current);

  AnimeVideo? get previous => _currentOrder?.before(current);

  EpisodeGroupOrder? get _currentOrder => orderOf(groupIndex);

  EpisodeGroupOrder? orderOf(int index) {
    if (index < 0 || index >= groups.length) {
      return null;
    }
    return _orders[index] ??= EpisodeGroupOrder(groups[index].elements);
  }

  EpisodePlaylist moveTo(AnimeVideo episode) {
    return EpisodePlaylist._(
      groups: groups,
      groupIndex: groupIndex,
      current: episode,
      orders: _orders,
    );
  }

  AnimeVideo? sameEpisodeIn(int targetGroupIndex) {
    final EpisodeGroupOrder? target = orderOf(targetGroupIndex);
    if (target == null || target.episodes.isEmpty) {
      return null;
    }
    final EpisodeOrderKey? key = episodeOrderKeyOf(current);
    if (key != null) {
      final AnimeVideo? byNumber = target.withKey(key);
      if (byNumber != null) {
        return byNumber;
      }
    }
    final List<AnimeVideo> ascending = target.ascending;
    final int ascendingIndex = _currentOrder?.ascendingIndexOf(current) ?? -1;
    if (ascendingIndex >= 0 && ascendingIndex < ascending.length) {
      return ascending[ascendingIndex];
    }
    return ascending.first;
  }

  EpisodePlaylist? switchGroup(int targetGroupIndex) {
    final AnimeVideo? episode = sameEpisodeIn(targetGroupIndex);
    if (episode == null) {
      return null;
    }
    return EpisodePlaylist._(
      groups: groups,
      groupIndex: targetGroupIndex,
      current: episode,
      orders: _orders,
    );
  }

  bool isAt(EpisodePlaylist other) {
    return other.groupIndex == groupIndex && other.current.uid == current.uid;
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodePlaylist &&
        identical(other.groups, groups) &&
        isAt(other);
  }

  @override
  int get hashCode => Object.hash(identityHashCode(groups), groupIndex, current.uid);
}
