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
      'createdAt': createdAt,
      'likes': likes,
      'likedBy': likedBy,
    };
  }
}
