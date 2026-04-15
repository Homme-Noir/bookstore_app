class OpdsEntry {
  const OpdsEntry({
    required this.title,
    required this.subtitle,
    required this.detailOrAcquisitionUrl,
    this.thumbnailUrl,
    this.epubUrl,
  });

  final String title;
  final String subtitle;
  /// Either a catalog link (needs second fetch) or direct acquisition.
  final String detailOrAcquisitionUrl;
  final String? thumbnailUrl;
  final String? epubUrl;

  bool get needsDetail => epubUrl == null;
}

class OpdsPage {
  const OpdsPage({
    required this.entries,
    this.nextUrl,
  });

  final List<OpdsEntry> entries;
  final String? nextUrl;
}
