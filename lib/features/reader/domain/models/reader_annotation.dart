class ReaderAnnotation {
  final String id;
  final String itemId;
  final String annotationId;
  final String note;
  final int start;
  final int end;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const ReaderAnnotation({
    required this.id,
    required this.itemId,
    required this.annotationId,
    required this.note,
    required this.start,
    required this.end,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  ReaderAnnotation copyWith({
    String? id,
    String? itemId,
    String? annotationId,
    String? note,
    int? start,
    int? end,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return ReaderAnnotation(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      annotationId: annotationId ?? this.annotationId,
      note: note ?? this.note,
      start: start ?? this.start,
      end: end ?? this.end,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'annotationId': annotationId,
        'note': note,
        'start': start,
        'end': end,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'version': version,
        'isDeleted': isDeleted,
      };

  factory ReaderAnnotation.fromJson(Map<String, dynamic> json) {
    return ReaderAnnotation(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      annotationId: json['annotationId'] as String? ?? json['id'] as String,
      note: json['note'] as String? ?? '',
      start: json['start'] as int? ?? 0,
      end: json['end'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      version: json['version'] as int? ?? 1,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}
