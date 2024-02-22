import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/category_model.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/models/grocery_model.dart';

class AddNewGrocery extends StatefulWidget {
  const AddNewGrocery({super.key});
  @override
  State<AddNewGrocery> createState() => _AddNewGroceryState();
}

class _AddNewGroceryState extends State<AddNewGrocery> {
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  String _selectedName = '';
  var _selectedQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  void _setItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });
      _formKey.currentState!.save();
      final url = Uri.https(
          'shoppy-fy-default-rtdb.firebaseio.com', 'shopping-list.json');

      final response = await http.post(
        url,
        headers: {'content-item': 'data/json'},
        body: json.encode(
          {
            'name': _selectedName,
            'quantity': _selectedQuantity,
            'category': _selectedCategory.title,
          },
        ),
      );

      final Map<String, dynamic> resData = json.decode(response.body);
      if (!context.mounted) {
        return;
      }
 Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _selectedName,
          quantity: _selectedQuantity,
          category: _selectedCategory,
        ),
      );
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
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      child: const Text('Reset')),
                  ElevatedButton(
                    onPressed: _isSending ? null : _setItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add item'),
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
