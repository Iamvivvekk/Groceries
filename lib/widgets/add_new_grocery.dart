import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/category_model.dart';
import 'package:http/http.dart' as http;

class AddNewGrocery extends StatefulWidget {
  const AddNewGrocery({super.key});
  @override
  State<AddNewGrocery> createState() => _AddNewGroceryState();
}

class _AddNewGroceryState extends State<AddNewGrocery> {
  final _formKey = GlobalKey<FormState>();
  String _selectedName = '';
  var _selectedQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  void _setItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https(
          'shoppy-fy-default-rtdb.firebaseio.com', 'shopping-list.json');

      http
          .post(url,
              headers: {'content-item': 'data/json'},
              body: json.encode(
                {
                  'name': _selectedName,
                  'quantity': _selectedQuantity,
                  'category': _selectedCategory.title,
                },
              ))
          .then((response) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Item added successfully'),
          duration: Duration(seconds: 2),
        ));
      });
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new gorcery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value == '' ||
                      value.trim().length == 1 ||
                      value.trim().length > 50) {
                    return 'Enter atleast two characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _selectedName = value!;
                },
              ),
              const SizedBox(
                height: 6,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _selectedQuantity.toString(),
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Quantity should be atleast 1';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _selectedQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 14,
                                  width: 14,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 8),
                                Text(category.value.title)
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        _formKey.currentState!.reset();
                      },
                      child: const Text('Reset')),
                  ElevatedButton(
                    onPressed: _setItem,
                    child: const Text('Add item'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
