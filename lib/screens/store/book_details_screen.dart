import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/book.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool _isInWishlist = false;
  final _reviewController = TextEditingController();
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _checkWishlistStatus() async {
    final isInWishlist =
        await context.read<AppProvider>().isInWishlist(widget.book.id);
    if (mounted) {
      setState(() => _isInWishlist = isInWishlist);
    }
  }

  Future<void> _toggleWishlist() async {
    if (_isInWishlist) {
      await context.read<AppProvider>().removeFromWishlist(widget.book.id);
    } else {
      await context.read<AppProvider>().addToWishlist(widget.book.id);
    }
    if (mounted) {
      setState(() => _isInWishlist = !_isInWishlist);
    }
  }

  Future<void> _addToCart() async {
    await context.read<AppProvider>().addToCart(widget.book, 1);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    final userId = context.read<AppProvider>().userId;
    if (userId == null) return;

    await context.read<AppProvider>().addReview(
          widget.book.id,
          _reviewController.text.trim(),
          _rating,
        );
    _reviewController.clear();
    setState(() => _rating = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.book.coverImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, size: 50),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.book.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isInWishlist
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _isInWishlist ? Colors.red : null,
                        ),
                        onPressed: _toggleWishlist,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${widget.book.author}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        widget.book.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${widget.book.reviewCount} reviews)',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '\$${widget.book.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.book.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: context
                        .read<AppProvider>()
                        .getBookReviews(widget.book.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final reviews = snapshot.data ?? [];

                      return Column(
                        children: [
                          ...reviews.map((review) => _ReviewCard(
                                review: review,
                                onLike: () =>
                                    context.read<AppProvider>().likeReview(
                                          widget.book.id,
                                          review['id'],
                                        ),
                              )),
                          const SizedBox(height: 16),
                          const Text(
                            'Write a Review',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < _rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  setState(() => _rating = index + 1);
                                },
                              );
                            }),
                          ),
                          TextField(
                            controller: _reviewController,
                            decoration: const InputDecoration(
                              hintText: 'Write your review...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _submitReview,
                            child: const Text('Submit Review'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _addToCart,
            child: const Text('Add to Cart'),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final VoidCallback onLike;

  const _ReviewCard({
    required this.review,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: review['userImage'] != null
                      ? NetworkImage(review['userImage'])
                      : null,
                  child: review['userImage'] == null
                      ? Text(review['userName'][0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['userName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            review['rating'].toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color: review['likedBy']?.contains(review['userId'])
                        ? Colors.blue
                        : null,
                  ),
                  onPressed: onLike,
                ),
                Text(review['likes'].toString()),
              ],
            ),
            const SizedBox(height: 8),
            Text(review['text']),
          ],
        ),
      ),
    );
  }
}
