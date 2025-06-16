import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/book.dart';

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
      _selectedCategory =
          widget.book!.genres.isNotEmpty
              ? widget.book!.genres.first
              : 'Fiction';
      _isBestseller = widget.book!.isBestseller;
      _isNewArrival = widget.book!.isNewArrival;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _coverImageController.dispose();
    super.dispose();
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
        genres: [_selectedCategory], // assuming dropdown feeds a single genre
        stock: widget.book?.stock ?? 0, // or add stock as a form field
        releaseDate: widget.book?.releaseDate ?? DateTime.now(),
        rating: widget.book?.rating ?? 0,
        reviewCount: widget.book?.reviewCount ?? 0,
        isBestseller: _isBestseller,
        isNewArrival: _isNewArrival,
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
            widget.book == null ? 'Book added successfully' : 'Book updated successfully',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
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
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _coverImageController,
                decoration: const InputDecoration(
                  labelText: 'Cover Image URL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a cover image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Fiction', child: Text('Fiction')),
                  DropdownMenuItem(value: 'Non-Fiction', child: Text('Non-Fiction')),
                  DropdownMenuItem(value: 'Science', child: Text('Science')),
                  DropdownMenuItem(value: 'History', child: Text('History')),
                  DropdownMenuItem(value: 'Biography', child: Text('Biography')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBook,
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