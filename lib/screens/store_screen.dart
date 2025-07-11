import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/cart_provider.dart';
import '../models/book.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const StoreTab(),
    );
  }
}

class StoreTab extends StatelessWidget {
  const StoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoadingBooks) {
          return const Center(child: CircularProgressIndicator());
        }

        if (appProvider.booksError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading books',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  appProvider.booksError!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => appProvider.loadBooks(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final books = appProvider.books;
        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No books available',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for new books',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          );
        }

        // Group books by category
        final Map<String, List<Book>> booksByCategory = {};
        for (final book in books) {
          final category =
              book.genres.isNotEmpty ? book.genres.first : 'General';
          booksByCategory.putIfAbsent(category, () => []).add(book);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Browse Books',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Discover amazing books from Open Library',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ...booksByCategory.entries.map((entry) {
                return _CategoryCarousel(
                  category: entry.key,
                  books: entry.value,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryCarousel extends StatelessWidget {
  final String category;
  final List<Book> books;

  const _CategoryCarousel({
    required this.category,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: _BookCard(book: book),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _showBookDetails(context, book),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  color: Colors.grey[200],
                ),
                child: book.coverImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        child: Image.network(
                          book.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.book,
                                  size: 40, color: Colors.grey),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.book, size: 40, color: Colors.grey),
                      ),
              ),
            ),
            // Book info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${book.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            final isInCart = cartProvider.isInCart(book.id);
                            final isAuthenticated =
                                context.read<AppProvider>().isAuthenticated;

                            return IconButton(
                              icon: Icon(
                                isInCart
                                    ? Icons.shopping_cart
                                    : Icons.add_shopping_cart,
                                size: 16,
                                color: isInCart ? Colors.green : Colors.grey,
                              ),
                              onPressed: () {
                                if (!isAuthenticated) {
                                  _showSignInDialog(context);
                                  return;
                                }

                                if (isInCart) {
                                  cartProvider.removeFromCart(
                                      context.read<AppProvider>().userId!,
                                      book.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Removed from cart'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } else {
                                  cartProvider.addToCart(
                                      context.read<AppProvider>().userId!,
                                      book);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to cart'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookDetails(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Book cover
              Center(
                child: Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: book.coverImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            book.coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.book,
                                    size: 40, color: Colors.grey),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.book, size: 40, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'By ${book.author}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Price: \$${book.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                book.description.isNotEmpty
                    ? book.description
                    : 'No description available.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        final isInCart = cartProvider.isInCart(book.id);
                        return ElevatedButton(
                          onPressed: () {
                            final isAuthenticated =
                                context.read<AppProvider>().isAuthenticated;

                            if (!isAuthenticated) {
                              Navigator.of(context).pop();
                              _showSignInDialog(context);
                              return;
                            }

                            if (isInCart) {
                              cartProvider.removeFromCart(
                                  context.read<AppProvider>().userId!, book.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Removed from cart'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            } else {
                              cartProvider.addToCart(
                                  context.read<AppProvider>().userId!, book);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to cart'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isInCart ? Colors.orange : Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                              isInCart ? 'Remove from Cart' : 'Add to Cart'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignInDialog(BuildContext context) {
    bool isGoogleLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Sign In Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please sign in to add items to your cart.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: isGoogleLoading
                    ? null
                    : () async {
                        setState(() {
                          isGoogleLoading = true;
                        });

                        try {
                          await context.read<AppProvider>().signInWithGoogle();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Successfully signed in with Google!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Google Sign-In failed: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              isGoogleLoading = false;
                            });
                          }
                        }
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.grey),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                ),
                icon: isGoogleLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      )
                    : Image.network(
                        'https://developers.google.com/identity/images/g-logo.png',
                        height: 20,
                        width: 20,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.g_mobiledata,
                            size: 20,
                            color: Colors.red,
                          );
                        },
                      ),
                label: Text(
                  isGoogleLoading ? 'Signing in...' : 'Sign in with Google',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
