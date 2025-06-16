import 'package:bookstore_app/widgets/custom_app_bar.dart';
import 'package:bookstore_app/widgets/loading_widget.dart';
import 'package:bookstore_app/models/book.dart';
import 'package:bookstore_app/widgets/cart_item_counter.dart'; 
import 'package:bookstore_app/providers/cart_provider.dart'; 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/order_card.dart';

class CartPage extends StatefulWidget {
  final String userId;

  const CartPage({super.key, required this.userId});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<String> cartList = [];
  double totalAmount = 0;
  static const String userCartListKey = 'userCartList';
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    prefs = await SharedPreferences.getInstance();
    cartList = prefs.getStringList(userCartListKey) ?? [];
    cartList.removeWhere((id) => id.isEmpty || id == 'null');

    if (!mounted) return;
    Provider.of<TotalAmount>(context, listen: false).display(0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCheckout,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.navigate_next),
        label: const Text('Check Out'),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: CustomAppBar()),

          // Total Price Display
          SliverToBoxAdapter(
            child: Consumer2<TotalAmount, CartItemCounter>(
              builder: (context, amountProvider, cartProvider, _) {
                return cartProvider.count == 0
                    ? const SizedBox.shrink()
                    : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'Total price: \$${amountProvider.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
              },
            ),
          ),

          // Cart List
          StreamBuilder<QuerySnapshot>(
            stream:
                cartList.isEmpty
                    ? null
                    : FirebaseFirestore.instance
                        .collection('books')
                        .where('isbn', whereIn: cartList)
                        .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(child: LoadingWidget()),
                );
              }

              final books = snapshot.data!.docs;
              if (books.isEmpty) return _buildEmptyCart();

              double runningTotal = 0;

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final book = BookModel.fromJson(
                    books[index].data() as Map<String, dynamic>,
                  );

                  runningTotal += book.price;

                  if (index == books.length - 1) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        Provider.of<TotalAmount>(
                          context,
                          listen: false,
                        ).display(runningTotal);
                      }
                    });
                  }

                  return sourceInfo(
                    book,
                    context,
                    background: Colors.purple,
                    removeCartFunction: () => _removeItemFromCart(book.isbn),
                  );
                }, childCount: books.length),
              );
            },
          ),
        ],
      ),
    );
  }

  void _goToCheckout() {
    if ((prefs.getStringList(userCartListKey) ?? []).isEmpty) {
      Fluttertoast.showToast(msg: 'No item in cart');
    } else {
      final amount =
          Provider.of<TotalAmount>(context, listen: false).totalAmount;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Address(totalAmount: amount)),
      );
    }
  }

  void _removeItemFromCart(String productId) async {
    final cart = prefs.getStringList(userCartListKey) ?? [];
    cart.remove(productId);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({userCartListKey: cart});

    await prefs.setStringList(userCartListKey, cart);

    Fluttertoast.showToast(msg: 'Item removed successfully');
    Provider.of<CartItemCounter>(context, listen: false).displayResult();

    setState(() {
      totalAmount = 0;
      cartList = cart;
    });
  }

  Widget _buildEmptyCart() {
    return SliverToBoxAdapter(
      child: Card(
        color: Theme.of(
          context,
        ).primaryColor.withAlpha(120), // fixed typo: withAlpha
        child: const SizedBox(
          height: 120,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, color: Colors.white),
                SizedBox(height: 8),
                Text('Your cart is empty'),
                Text('Start adding items!'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
