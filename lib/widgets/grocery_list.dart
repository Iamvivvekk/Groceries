import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/grocery_model.dart';
import 'package:shopping_app/widgets/add_new_grocery.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  String? _error;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    loadItem();
  }

  void loadItem() async {
    final url = Uri.https(
        'shoppy-fy-default-rtdb.firebaseio.com', 'shopping-list.json');

    try {
      final response = await http.get(url);
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> loadedData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (var item in loadedData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;

        loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ));
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong, please try later...';
      });
    }
  }

  final Map<String, Map<String, dynamic>> receivedData = {};
  void _onAddNewGrocery() async {
    final GroceryItem newItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewGrocery(),
      ),
    );
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _onDismissedRemoveItem(int index, GroceryItem gItem) async {
    final url = Uri.https('shoppy-fy-default-rtdb.firebaseio.com',
        'shopping-list/${gItem.id}.json');
    http.delete(url);
    _groceryItems.remove(gItem);
    if (_groceryItems.isEmpty) {
      setState(() {});
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Item removed successfully'),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _groceryItems.insert(index, gItem);
            });
          }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        'Uh oh...\n No Groceries added',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold),
      ),
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isEmpty) {
      content = Center(
        child: Text(
          'No items added yet.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold),
        ),
      );
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            background: Container(
              margin: const EdgeInsets.all(8),
              color: Colors.red,
            ),
            onDismissed: (direction) {
              _onDismissedRemoveItem(index, _groceryItems[index]);
            },
            key: ValueKey(_groceryItems[index].id),
            child: Container(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                tileColor: Theme.of(context).colorScheme.onPrimary,
                leading: Container(
                  color: _groceryItems[index].category.color,
                  height: 24,
                  width: 24,
                ),
                title: Text(_groceryItems[index].name),
                trailing: Text(_groceryItems[index].quantity.toString()),
              ),
            ),
          );
        },
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold),
        ),
      );
    }
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(
              onPressed: _onAddNewGrocery,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: content);
  }
}
