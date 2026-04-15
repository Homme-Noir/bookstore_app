class DiscoveryResult {
  final String id;
  final String title;
  final String author;
  final String source;
  final String format;
  final String? coverUrl;
  final String? downloadUrl;
  /// BitTorrent magnet (e.g. from Anna's Archive); open with an external torrent client.
  final String? magnetUrl;
  /// Optional catalog page (e.g. Open Library work URL) for context when no file URL exists.
  final String? catalogUrl;
  final double confidence;
  final bool formatVerified;
  final List<String> qualityFlags;

  const DiscoveryResult({
    required this.id,
    required this.title,
    required this.author,
    required this.source,
    required this.format,
    this.coverUrl,
    this.downloadUrl,
    this.magnetUrl,
    this.catalogUrl,
    this.confidence = 0.5,
    this.formatVerified = false,
    this.qualityFlags = const [],
  });

  bool get hasDownload =>
      downloadUrl != null && downloadUrl!.trim().isNotEmpty;

  bool get hasMagnet =>
      magnetUrl != null && magnetUrl!.trim().isNotEmpty;

  /// True when we have a direct HTTP file URL (importable in-app).
  bool get hasDirectHttpDownload => hasDownload;

  /// True when user can acquire the book via HTTP import and/or an external torrent app.
  bool get canAcquire => hasDirectHttpDownload || hasMagnet;
}
