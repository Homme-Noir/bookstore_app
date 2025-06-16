import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/book.dart';
import '../../widgets/custom_app_bar.dart';

class SearchService {
  Future<QuerySnapshot> searchByName(String searchField) {
    return FirebaseFirestore.instance
        .collection('books')
        .where('title', isGreaterThanOrEqualTo: searchField)
        .get();
  }
}

class SearchProduct extends StatefulWidget {
  const SearchProduct({super.key});

  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  late Future<QuerySnapshot> documnetList;

  Future<void> initSearch(String query) async {
    if (query.isEmpty) return;

    final capitalizedValue = query[0].toUpperCase() + query.substring(1);

    documnetList =
        FirebaseFirestore.instance
            .collection('books')
            .where('title', isGreaterThanOrEqualTo: capitalizedValue)
            .get();

    setState(() {});
  }

  Widget searchWidget() {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: 80.0,
      color: Colors.blueGrey,
      child: Container(
        width: MediaQuery.of(context).size.width - 40.0,
        height: 50.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.search, color: Colors.blueGrey),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(
                  onChanged: (val) {
                    initSearch(val);
                  },
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Search',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Search Books',
          showCart: true,
          showBackButton: true,
          actions: [],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: searchWidget(),
          ),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: documnetList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No data'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                final model = BookModel.fromJson(data);
                return buildResultCard(model);
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildResultCard(BookModel model) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 2.0,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(model.title, style: const TextStyle(fontSize: 18.0)),
        subtitle: Text(model.author ?? "Unknown Author"),
        onTap: () {
          // Add navigation to detail page here if needed
        },
      ),
    );
  }
}
