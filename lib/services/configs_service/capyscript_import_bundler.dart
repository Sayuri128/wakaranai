import 'package:path/path.dart' as path;
import 'package:wakaranai/data/models/remote_script/remote_script.dart';

class CapyscriptImportBundler {
  static final RegExp _importPattern = RegExp(
    r'''^\s*import\s+["']([^"']+)["'];\s*$''',
    multiLine: true,
  );

  static Future<RemoteScript> bundle({
    required String entryPath,
    required Future<RemoteScript> Function(String path) fetchScript,
  }) async {
    final _BundledScript bundled = await _bundleScript(
      path: _normalizePath(entryPath),
      fetchScript: fetchScript,
      visitedPaths: <String>{},
    );

    final List<String> imports = <String>[];
    final Set<String> seenImports = <String>{};
    for (final String importLine in bundled.imports) {
      if (seenImports.add(importLine)) {
        imports.add(importLine);
      }
    }

    final List<String> sections = <String>[
      if (imports.isNotEmpty) imports.join('\n'),
      ...bundled.bodies.where((String body) => body.trim().isNotEmpty),
    ];

    return RemoteScript(
      path: _normalizePath(entryPath),
      script: sections.join('\n\n'),
    );
  }

  static Future<_BundledScript> _bundleScript({
    required String path,
    required Future<RemoteScript> Function(String path) fetchScript,
    required Set<String> visitedPaths,
  }) async {
    final String normalizedPath = _normalizePath(path);
    if (!visitedPaths.add(normalizedPath)) {
      return const _BundledScript();
    }

    final RemoteScript remoteScript = await fetchScript(normalizedPath);
    final Iterable<RegExpMatch> imports =
        _importPattern.allMatches(remoteScript.script);

    final List<String> collectedImports = <String>[];
    final List<String> collectedBodies = <String>[];

    for (final RegExpMatch importMatch in imports) {
      final String importValue = importMatch.group(1)!;
      final String importLine = importMatch.group(0)!.trim();

      if (_isRelativeImport(importValue)) {
        final _BundledScript bundledImport = await _bundleScript(
          path: _resolveImportPath(
            currentPath: normalizedPath,
            importPath: importValue,
          ),
          fetchScript: fetchScript,
          visitedPaths: visitedPaths,
        );
        collectedImports.addAll(bundledImport.imports);
        collectedBodies.addAll(bundledImport.bodies);
        continue;
      }

      collectedImports.add(importLine);
    }

    final String scriptBody = remoteScript.script
        .replaceAllMapped(_importPattern, (Match match) => '')
        .trim();
    if (scriptBody.isNotEmpty) {
      collectedBodies.add(scriptBody);
    }

    return _BundledScript(
      imports: collectedImports,
      bodies: collectedBodies,
    );
  }

  static bool _isRelativeImport(String importPath) {
    return importPath.startsWith('./') || importPath.startsWith('../');
  }

  static String _resolveImportPath({
    required String currentPath,
    required String importPath,
  }) {
    final String resolvedPath =
        path.normalize(path.join(path.dirname(currentPath), importPath));
    return _normalizePath(resolvedPath);
  }

  static String _normalizePath(String scriptPath) {
    final String normalizedPath = path.normalize(scriptPath);
    if (path.extension(normalizedPath).isEmpty) {
      return '$normalizedPath.capyscript';
    }
    return normalizedPath;
  }
}

class _BundledScript {
  final List<String> imports;
  final List<String> bodies;

  const _BundledScript({
    this.imports = const <String>[],
    this.bodies = const <String>[],
  });
}
