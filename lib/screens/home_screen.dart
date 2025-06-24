import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/book.dart';
import 'auth/login_screen.dart';
import 'library_screen.dart';
import '../providers/cart_provider.dart';
import '../providers/profile_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isAuthenticated) {
          return const MainAppScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  @override
  void initState() {
    super.initState();
    // Load books when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadBooks();
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Store'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Cart icon with badge
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AppProvider>().signOut();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: const HomeTab(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    return Text(
                      appProvider.userId ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const Text(
                  'Book Store App',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Store'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/store');
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('My Library'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/library');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Shopping Cart'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/cart');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          // Admin Dashboard (only for admin)
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              if (profileProvider.email == 'admin@bookstore.com') {
                return ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Admin Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/admin');
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pop(context);
              context.read<AppProvider>().signOut();
            },
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Book Store',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your personal library management app',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'My Library',
                      subtitle: 'Your purchased books',
                      icon: Icons.library_books,
                      color: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, '/library');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Shopping Cart',
                      subtitle: 'View your cart',
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Wishlist',
                      subtitle: 'Books you want to read',
                      icon: Icons.favorite_border,
                      color: Colors.red,
                      onTap: () {
                        Navigator.pushNamed(context, '/library');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Favorites',
                      subtitle: 'Your favorite books',
                      icon: Icons.star,
                      color: Colors.amber,
                      onTap: () {
                        Navigator.pushNamed(context, '/library');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Featured Books
              const Text(
                'Featured Books',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _FeaturedBooksSection(),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedBooksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.books.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.book,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No books available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Visit the store to discover books',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: appProvider.books.take(6).length,
          itemBuilder: (context, index) {
            final book = appProvider.books[index];
            return _BookCard(book: book);
          },
        );
      },
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
        onTap: () {
          showBookDetailsDialog(context, book);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey[200],
                ),
                child: book.coverImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          book.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.book,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.book,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}

void showBookDetailsDialog(BuildContext context, Book book) {
  final appProvider = Provider.of<AppProvider>(context, listen: false);
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  final isPurchased = appProvider.isBookPurchased(book.id);
  final isInWishlist = appProvider.isInWishlist(book.id);
  final isInFavourites = appProvider.isInFavourites(book.id);
  final isInCart = cartProvider.isInCart(book.id);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(book.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (book.coverImage.isNotEmpty)
              Center(
                child: Image.network(
                  book.coverImage,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.book, size: 100);
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text('Author: ${book.author}'),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(
                    5,
                    (i) => Icon(
                          i < book.rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 18,
                          color: Colors.amber[600],
                        )),
                const SizedBox(width: 8),
                Text(book.rating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Price: \$${book.price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Description: ${book.description}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        IconButton(
          onPressed: () async {
            if (isInWishlist) {
              await appProvider.removeFromWishlist(book.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Removed from wishlist')),
                );
              }
            } else {
              await appProvider.addToWishlist(book);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to wishlist!')),
                );
              }
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          icon: Icon(
            isInWishlist ? Icons.favorite : Icons.favorite_border,
            color: isInWishlist ? Colors.red : null,
          ),
          tooltip: isInWishlist ? 'Remove from wishlist' : 'Add to wishlist',
        ),
        IconButton(
          onPressed: () async {
            if (isInFavourites) {
              await appProvider.removeFromFavourites(book.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Removed from favorites')),
                );
              }
            } else {
              await appProvider.addToFavourites(book);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to favorites!')),
                );
              }
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          icon: Icon(
            isInFavourites ? Icons.star : Icons.star_border,
            color: isInFavourites ? Colors.amber : null,
          ),
          tooltip:
              isInFavourites ? 'Remove from favorites' : 'Add to favorites',
        ),
        if (!isPurchased)
          ElevatedButton(
            onPressed: isInCart
                ? null
                : () async {
                    await cartProvider.addToCart(book);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart!')),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isInCart ? Colors.grey : Colors.blue,
            ),
            child: Text(isInCart ? 'In Cart' : 'Add to Cart'),
          ),
        if (isPurchased)
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Purchased'),
          ),
      ],
    ),
  );
}

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const LibraryScreen();
  }
}
