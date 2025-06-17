import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/book.dart';
import 'search_screen.dart';
import 'book_details_screen.dart';

/// A screen that displays a list of books with filtering and pagination options.
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

/// The state for the StoreScreen.
class _StoreScreenState extends State<StoreScreen> {
  /// The currently selected category for filtering books.
  String _selectedCategory = 'All';

  /// The currently selected sort option for ordering books.
  String _selectedSort = 'Newest';

  /// The number of books to display per page.
  final int _pageSize = 10;

  /// The current page number for pagination.
  final int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final categories = ['All', ...provider.categories];
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Store'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SearchScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Books'),
              Tab(text: 'Bestsellers'),
              Tab(text: 'New Arrivals'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSort,
                      decoration: const InputDecoration(
                        labelText: 'Sort By',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Newest', child: Text('Newest')),
                        DropdownMenuItem(
                          value: 'Price: Low to High',
                          child: Text('Price: Low to High'),
                        ),
                        DropdownMenuItem(
                          value: 'Price: High to Low',
                          child: Text('Price: High to Low'),
                        ),
                        DropdownMenuItem(
                          value: 'Rating',
                          child: Text('Rating'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedSort = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  StreamBuilder<List<Book>>(
                    stream: provider.getBooksFiltered(
                      category:
                          _selectedCategory == 'All' ? null : _selectedCategory,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final books = snapshot.data ?? [];

                      if (books.isEmpty) {
                        return const Center(
                          child: Text('No books found'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: Image.network(
                                book.coverImage,
                                width: 60,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                              title: Text(book.title),
                              subtitle:
                                  Text('\$${book.price.toStringAsFixed(2)}'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookDetailsScreen(book: book),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<List<Book>>(
                    stream: provider.getBestsellers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final books = snapshot.data ?? [];

                      if (books.isEmpty) {
                        return const Center(
                          child: Text('No bestsellers found'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: Image.network(
                                book.coverImage,
                                width: 60,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                              title: Text(book.title),
                              subtitle:
                                  Text('\$${book.price.toStringAsFixed(2)}'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookDetailsScreen(book: book),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<List<Book>>(
                    stream: provider.getNewArrivals(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final books = snapshot.data ?? [];

                      if (books.isEmpty) {
                        return const Center(
                          child: Text('No new arrivals found'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: Image.network(
                                book.coverImage,
                                width: 60,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                              title: Text(book.title),
                              subtitle:
                                  Text('\$${book.price.toStringAsFixed(2)}'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookDetailsScreen(book: book),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
