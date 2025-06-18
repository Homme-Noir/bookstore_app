import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/book.dart';
import '../../dialogs/book_search_dialog.dart';

class BookEditScreen extends StatefulWidget {
  final Book? book;

  const BookEditScreen({super.key, this.book});

  @override
  State<BookEditScreen> createState() => _BookEditScreenState();
}

class _BookEditScreenState extends State<BookEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _coverImageController = TextEditingController();
  final _isbnController = TextEditingController();
  final _stockController = TextEditingController();
  final _pageCountController = TextEditingController();

  String _selectedCategory = 'Fiction';
  bool _isBestseller = false;
  bool _isNewArrival = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _descriptionController.text = widget.book!.description;
      _priceController.text = widget.book!.price.toString();
      _coverImageController.text = widget.book!.coverImage;
      _isbnController.text = widget.book!.isbn ?? '';
      _stockController.text = widget.book!.stock.toString();
      _pageCountController.text = widget.book!.pageCount?.toString() ?? '';
      _selectedCategory = widget.book!.genres.isNotEmpty
          ? widget.book!.genres.first
          : 'Fiction';
      _isBestseller = widget.book!.isBestseller;
      _isNewArrival = widget.book!.isNewArrival;
    } else {
      _stockController.text = '0';
      _priceController.text = '0.00';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _coverImageController.dispose();
    _isbnController.dispose();
    _stockController.dispose();
    _pageCountController.dispose();
    super.dispose();
  }

  Future<void> _searchBookFromOpenLibrary() async {
    final Book? selectedBook = await showDialog<Book>(
      context: context,
      builder: (context) => const BookSearchDialog(),
    );

    if (selectedBook != null && mounted) {
      setState(() {
        _titleController.text = selectedBook.title;
        _authorController.text = selectedBook.author;
        _descriptionController.text = selectedBook.description;
        _coverImageController.text = selectedBook.coverImage;
        _isbnController.text = selectedBook.isbn ?? '';
        _pageCountController.text = selectedBook.pageCount?.toString() ?? '';

        // Set category if available
        if (selectedBook.genres.isNotEmpty) {
          _selectedCategory = selectedBook.genres.first;
        }

        // Set release date if available
        if (selectedBook.releaseDate != DateTime.now()) {
          // You might want to add a date picker for this
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book data loaded from Open Library'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final book = Book(
        id: widget.book?.id ?? '',
        title: _titleController.text,
        author: _authorController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        coverImage: _coverImageController.text,
        genres: [_selectedCategory],
        stock: int.parse(_stockController.text),
        releaseDate: widget.book?.releaseDate ?? DateTime.now(),
        rating: widget.book?.rating ?? 0,
        reviewCount: widget.book?.reviewCount ?? 0,
        isBestseller: _isBestseller,
        isNewArrival: _isNewArrival,
        isbn: _isbnController.text.isNotEmpty ? _isbnController.text : null,
        pageCount: _pageCountController.text.isNotEmpty
            ? int.parse(_pageCountController.text)
            : null,
        status: 'available',
      );

      if (widget.book == null) {
        await context.read<AppProvider>().addBook(book);
      } else {
        await context.read<AppProvider>().updateBook(book);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.book == null
                ? 'Book added successfully'
                : 'Book updated successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add Book' : 'Edit Book'),
        actions: [
          if (widget.book == null) // Only show search for new books
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _searchBookFromOpenLibrary,
              tooltip: 'Search Open Library',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search from Open Library button (for new books)
              if (widget.book == null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.library_books,
                          color: Colors.blue, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'Search Open Library',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Find book details automatically from Open Library database',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _searchBookFromOpenLibrary,
                        icon: const Icon(Icons.search),
                        label: const Text('Search Books'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Author Field
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ISBN Field
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(
                  labelText: 'ISBN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price and Stock Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price *',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Page Count Field
              TextFormField(
                controller: _pageCountController,
                decoration: const InputDecoration(
                  labelText: 'Page Count',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pages),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Cover Image Field
              TextFormField(
                controller: _coverImageController,
                decoration: const InputDecoration(
                  labelText: 'Cover Image URL *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a cover image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'Fiction', child: Text('Fiction')),
                  DropdownMenuItem(
                      value: 'Non-Fiction', child: Text('Non-Fiction')),
                  DropdownMenuItem(value: 'Science', child: Text('Science')),
                  DropdownMenuItem(value: 'History', child: Text('History')),
                  DropdownMenuItem(
                      value: 'Biography', child: Text('Biography')),
                  DropdownMenuItem(value: 'Mystery', child: Text('Mystery')),
                  DropdownMenuItem(value: 'Romance', child: Text('Romance')),
                  DropdownMenuItem(value: 'Fantasy', child: Text('Fantasy')),
                  DropdownMenuItem(
                      value: 'Self-Help', child: Text('Self-Help')),
                  DropdownMenuItem(value: 'Business', child: Text('Business')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Checkboxes
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Bestseller'),
                      value: _isBestseller,
                      onChanged: (value) {
                        setState(() => _isBestseller = value ?? false);
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('New Arrival'),
                      value: _isNewArrival,
                      onChanged: (value) {
                        setState(() => _isNewArrival = value ?? false);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBook,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(widget.book == null ? 'Add Book' : 'Update Book'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
