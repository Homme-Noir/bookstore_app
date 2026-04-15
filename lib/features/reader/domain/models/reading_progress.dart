class ReadingProgress {
  final String itemId;
  final double percentage;
  final int position;
  final DateTime updatedAt;

  const ReadingProgress({
    required this.itemId,
    required this.percentage,
    required this.position,
    required this.updatedAt,
  });

  ReadingProgress copyWith({
    String? itemId,
    double? percentage,
    int? position,
    DateTime? updatedAt,
  }) {
    return ReadingProgress(
      itemId: itemId ?? this.itemId,
      percentage: percentage ?? this.percentage,
      position: position ?? this.position,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'percentage': percentage,
        'position': position,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      itemId: json['itemId'] as String,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      position: json['position'] as int? ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
