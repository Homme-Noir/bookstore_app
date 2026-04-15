class LibraryItem {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final String format;
  final String? sourceUrl;
  final String? checksum;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double progress;
  final bool isFinished;
  final List<String> tags;

  const LibraryItem({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.format,
    this.sourceUrl,
    this.checksum,
    required this.createdAt,
    required this.updatedAt,
    this.progress = 0,
    this.isFinished = false,
    this.tags = const [],
  });

  LibraryItem copyWith({
    String? id,
    String? title,
    String? author,
    String? filePath,
    String? format,
    String? sourceUrl,
    String? checksum,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? progress,
    bool? isFinished,
    List<String>? tags,
  }) {
    return LibraryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath ?? this.filePath,
      format: format ?? this.format,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      checksum: checksum ?? this.checksum,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      progress: progress ?? this.progress,
      isFinished: isFinished ?? this.isFinished,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'filePath': filePath,
        'format': format,
        'sourceUrl': sourceUrl,
        'checksum': checksum,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'progress': progress,
        'isFinished': isFinished,
        'tags': tags,
      };

  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    return LibraryItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled',
      author: json['author'] as String? ?? 'Unknown Author',
      filePath: json['filePath'] as String? ?? '',
      format: json['format'] as String? ?? 'unknown',
      sourceUrl: json['sourceUrl'] as String?,
      checksum: json['checksum'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      isFinished: json['isFinished'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}
