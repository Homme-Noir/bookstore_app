import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/book.dart';
import 'book_details_screen.dart';
import 'search_screen.dart';

/// A screen that displays a list of books with filtering and pagination options.
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

/// The state for the StoreScreen.
class _StoreScreenState extends State<StoreScreen> {
  /// The currently selected category for filtering books.
  String? _selectedCategory;
  /// The currently selected sort option for ordering books.
  String _selectedSort = 'Newest';
  /// The number of books to display per page.
  final int _pageSize = 10;
  /// The current page number for pagination.
  int _currentPage = 1;

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
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory ?? 'All',
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: categories
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val == 'All' ? null : val;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSort,
                      decoration: const InputDecoration(labelText: 'Sort by'),
                      items: const [
                        DropdownMenuItem(value: 'Newest', child: Text('Newest')),
                        DropdownMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
                        DropdownMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
                        DropdownMenuItem(value: 'Rating', child: Text('Rating')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedSort = val!;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _BookGrid(
                    stream: provider.getBooksFiltered(
                      category: _selectedCategory,
                      sort: _selectedSort,
                      pageSize: _pageSize * _currentPage,
                    ),
                    onLoadMore: () {
                      setState(() => _currentPage++);
                    },
                    canLoadMore: true, // TODO: Set to false if no more data
                  ),
                  _BookGrid(
                    stream: provider.getBestsellersFiltered(
                      category: _selectedCategory,
                      sort: _selectedSort,
                      pageSize: _pageSize * _currentPage,
                    ),
                    onLoadMore: () {
                      setState(() => _currentPage++);
                    },
                    canLoadMore: true,
                  ),
                  _BookGrid(
                    stream: provider.getNewArrivalsFiltered(
                      category: _selectedCategory,
                      sort: _selectedSort,
                      pageSize: _pageSize * _currentPage,
                    ),
                    onLoadMore: () {
                      setState(() => _currentPage++);
                    },
                    canLoadMore: true,
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

/// A widget that displays a grid of books with pagination.
class _BookGrid extends StatelessWidget {
  /// The stream of books to display.
  final Stream<List<Book>> stream;
  /// Callback function to load more books.
  final VoidCallback onLoadMore;
  /// Whether more books can be loaded.
  final bool canLoadMore;

  const _BookGrid({required this.stream, required this.onLoadMore, required this.canLoadMore});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Book>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
        }

        final books = snapshot.data ?? [];

        if (books.isEmpty) {
          return const Center(child: Text('No books found'));
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return _BookCard(book: book);
                },
              ),
            ),
            if (canLoadMore)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: onLoadMore,
                  child: const Text('Load More'),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A widget that displays a book card.
class _BookCard extends StatelessWidget {
  /// The book to display.
  final Book book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookDetailsScreen(book: book),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                book.coverImage,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${book.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            book.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
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