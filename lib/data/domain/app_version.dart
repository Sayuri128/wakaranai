class AppVersion {
  final int major;
  final int minor;
  final int patch;

  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
  });

  static final RegExp regex = RegExp(r"\d+\.\d+\.\d+");

  factory AppVersion.fromString(String version) {
    if (!regex.hasMatch(version)) {
      throw Exception("Invalid version string: $version");
    }
    final RegExpMatch? versionResult = regex.firstMatch(version);
    if (versionResult == null) {
      throw Exception("Invalid version string: $version");
    }
    final String versionStr = versionResult.group(0)!;

    final List<String> parts = versionStr.split(".");
    if (parts.length != 3) {
      throw Exception("Invalid version string: $version");
    }

    final int major = int.parse(parts[0]);
    final int minor = int.parse(parts[1]);
    final int patch = int.parse(parts[2]);

    return AppVersion(
      major: major,
      minor: minor,
      patch: patch,
    );
  }

  bool operator >(AppVersion other) =>
      major > other.major ||
      (major == other.major && minor > other.minor) ||
      (major == other.major && minor == other.minor && patch > other.patch);

  bool operator <(AppVersion other) =>
      major < other.major ||
      (major == other.major && minor < other.minor) ||
      (major == other.major && minor == other.minor && patch < other.patch);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppVersion &&
          runtimeType == other.runtimeType &&
          major == other.major &&
          minor == other.minor &&
          patch == other.patch;

  @override
  int get hashCode => major.hashCode ^ minor.hashCode ^ patch.hashCode;

  @override
  String toString() {
    return "$major.$minor.$patch";
  }
}
