import 'dart:convert';

class Review {
  final String id;
  final String bookId;
  final String userId;
  final String userName;
  final String userImage;
  final String comment;
  final double rating;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;

  Review({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.comment,
    required this.rating,
    required this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'comment': comment,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'likedBy': likedBy,
    };
  }

  static Review fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String,
      bookId: map['bookId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userImage: map['userImage'] as String,
      comment: map['comment'] as String,
      rating: (map['rating'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      likes: map['likes'] as int? ?? 0,
      likedBy: map['likedBy'] != null
          ? List<String>.from(jsonDecode(map['likedBy'] as String))
          : [],
    );
  }
}
