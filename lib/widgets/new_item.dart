import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/data/categories.dart';
import 'package:shop/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = "";
  int _enteredQuantity = 0;
  var _selectedCategory = categories[Categories.fruit]!;
  bool _isLoading = false;

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      http
          .post(
              Uri.https('flutter-project-e0227-default-rtdb.firebaseio.com',
                  'shopping-list.json'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode({
                "name": _enteredName,
                "quantity": _enteredQuantity,
                "category": _selectedCategory.title,
              }))
          .then(
        (response) {
          final Map<String, dynamic> resData = json.decode(response.body);
          if (response.statusCode == 200) {
            Navigator.of(context).pop(GroceryItem(
                id: resData['name'],
                name: _enteredName,
                quantity: _enteredQuantity,
                category: _selectedCategory));
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add new item",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (newValue) => _enteredName = newValue!,
                decoration: const InputDecoration(labelText: 'Name:'),
                validator: (String? value) => value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50
                    ? "Must be between 1 and 50 charachters."
                    : null,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      onSaved: (newValue) =>
                          _enteredQuantity = int.parse(newValue!),
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity:'),
                      validator: (String? value) => value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0
                          ? "Must be a valid, positive number."
                          : null,
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                      child: DropdownButtonFormField(
                    value: _selectedCategory,
                    items: [
                      for (final category in categories.entries)
                        DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  category.value.title,
                                ),
                              ],
                            ))
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ))
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                ElevatedButton(
                  onPressed: _isLoading
                      ? null // is disaplaid cannot be make change in page
                      : () {
                          _formKey.currentState!.reset();
                        },
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveItem,
                  child: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.green,
                          ),
                        )
                      : const Text('Add Item'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
