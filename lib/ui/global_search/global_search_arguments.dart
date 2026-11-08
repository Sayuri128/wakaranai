class GlobalSearchArguments {
  const GlobalSearchArguments({
    this.query,
    this.alternativeQueries = const <String>[],
  });

  final String? query;
  final List<String> alternativeQueries;
}
