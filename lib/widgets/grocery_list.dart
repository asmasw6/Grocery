import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/data/categories.dart';
import 'package:shop/models/category.dart';
import 'package:shop/models/grocery_item.dart';
import 'package:shop/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  String? _error;

  void _loadData() async {
    final http.Response response = await http
        .get(
      Uri.https('flutter-project-e0227-default-rtdb.firebaseio.com',
          'shopping-list.json'),
    )
        .catchError((_) {
      return http.Response("", 400); // if Network is bad
    });
    // if failed
    if (response.statusCode >= 404) {
      setState(() {
        _error = "Failed to ftch data. Please try again later.";
      });
      return;
    } else if (json.decode(response.body) == null) {
      // if null that mean og delete all entries on this db

      setState(() {
        _isLoading = false;
      });
      return;
    } else {
      final Map<String, dynamic> loadedData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (var item in loadedData.entries) {
        final Category category = categories.entries
            .firstWhere(
              (element) => element.value.title == item.value['category'],
            )
            .value;
        loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ));

        setState(() {
          _groceryItems = loadedItems;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    Widget content = const Center(
      child: Text("No Item added yet."),
    );

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(_groceryItems[index].id),
            onDismissed: (direction) {
              _removeItem(_groceryItems[index]);
            },
            background: Container(
              decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(15)),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: AnimatedSwitcher(
                duration: const Duration(microseconds: 500),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: Tween<double>(begin: .8, end: 1).animate(animation),
                    child: child,
                  );
                },
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  key: ValueKey<int>(index),
                ),
              ), // Add an icon if needed.
            ),
            child: ListTile(
              title: Text(
                _groceryItems[index].name,
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 16),
              ),
              leading: Container(
                height: 24,
                width: 24,
                decoration:
                    BoxDecoration(color: _groceryItems[index].category.color),
              ),
              trailing: Text(
                _groceryItems[index].quantity.toString(),
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 16),
              ),
            ),
          );
        },
      );
    }
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Grocery",
          ),
          actions: [
            IconButton(
              onPressed: _addItem,
              icon: Icon(
                Icons.add,
                color: Theme.of(context).primaryColor,
              ),
            )
          ],
        ),
        body: content);
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final http.Response response = await http.delete(
      Uri.https('flutter-project-e0227-default-rtdb.firebaseio.com',
          'shopping-list/${item.id}.json'),
    );
    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("We could not delete the item."),
        ),
      );
      _groceryItems.insert(index, item);
    }
  }

  _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    } else {
      setState(() {
        _groceryItems.add(newItem);
        _isLoading = false;
      });
    }
  }
}
