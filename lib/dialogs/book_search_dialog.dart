import 'package:flutter/material.dart';
import '../services/open_library_service.dart';

class BookSearchDialog extends StatefulWidget {
  const BookSearchDialog({super.key});

  @override
  State<BookSearchDialog> createState() => _BookSearchDialogState();
}

class _BookSearchDialogState extends State<BookSearchDialog> {
  final OpenLibraryService _openLibraryService = OpenLibraryService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();

  List<OpenLibraryBook> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _searchBooks() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results =
          await _openLibraryService.searchBooks(_searchController.text.trim());
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchByIsbn() async {
    if (_isbnController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final book =
          await _openLibraryService.getBookByIsbn(_isbnController.text.trim());
      setState(() {
        _searchResults = book != null ? [book] : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _selectBook(OpenLibraryBook olBook) {
    final book = _openLibraryService.convertToBook(olBook);
    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Search Books',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Bar
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Search by Title/Author'),
                      Tab(text: 'Search by ISBN'),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                  ),
                  const SizedBox(height: 16),

                  // Tab Content
                  SizedBox(
                    height: 120,
                    child: TabBarView(
                      children: [
                        // Search by Title/Author Tab
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter book title or author...',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                    onSubmitted: (_) => _searchBooks(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _searchBooks,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('Search'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_errorMessage != null)
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                          ],
                        ),

                        // Search by ISBN Tab
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _isbnController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter ISBN...',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.qr_code),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSubmitted: (_) => _searchByIsbn(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _searchByIsbn,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('Search'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_errorMessage != null)
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            'No books found. Try searching for a book title, author, or ISBN.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final book = _searchResults[index];
                            return _BookSearchResultCard(
                              book: book,
                              onSelect: () => _selectBook(book),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookSearchResultCard extends StatelessWidget {
  final OpenLibraryBook book;
  final VoidCallback onSelect;

  const _BookSearchResultCard({
    required this.book,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: book.coverImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  book.coverImage!,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 70,
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, color: Colors.grey),
                    );
                  },
                ),
              )
            : Container(
                width: 50,
                height: 70,
                color: Colors.grey[300],
                child: const Icon(Icons.book, color: Colors.grey),
              ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.authors.isNotEmpty)
              Text(
                'By ${book.authors.join(', ')}',
                style: const TextStyle(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (book.publishDate != null)
              Text(
                'Published: ${book.publishDate!.year}',
                style: const TextStyle(color: Colors.grey),
              ),
            if (book.isbn != null)
              Text(
                'ISBN: ${book.isbn}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onSelect,
          child: const Text('Select'),
        ),
        onTap: onSelect,
      ),
    );
  }
}
