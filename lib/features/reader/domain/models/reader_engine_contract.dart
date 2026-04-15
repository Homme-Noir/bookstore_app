class ReaderEnginePosition {
  const ReaderEnginePosition({
    required this.itemId,
    required this.progress,
    required this.location,
    required this.engine,
  });

  final String itemId;
  final double progress;
  final int location;
  final String engine;
}

