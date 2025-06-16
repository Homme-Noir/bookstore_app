import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userImage: data['userImage'] ?? '',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'comment': comment,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'likedBy': likedBy,
    };
  }
} 