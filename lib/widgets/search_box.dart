import 'package:flutter/material.dart';
import '../services/book_service.dart';

class SearchBoxDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final bookService = BookService();
    return StreamBuilder(
      stream: bookService.searchBooksStream(query),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error occurred'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final books = snapshot.data!;
        if (books.isEmpty) {
          return const Center(child: Text('No books found'));
        }

        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return ListTile(
              title: Text(book.title),
              subtitle: Text('\$${book.price.toStringAsFixed(2)}'),
              onTap: () {
                close(context, book);
              },
            );
          },
        );
      },
    );
  }
}
