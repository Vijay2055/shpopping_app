import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/data/category.dart';
import 'package:shopping_app/models/category.dart';

import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/screen/form_screen.dart';

class GroceryWidgets extends StatefulWidget {
  const GroceryWidgets({super.key});

  @override
  State<GroceryWidgets> createState() => _GroceryWidgetsState();
}

class _GroceryWidgetsState extends State<GroceryWidgets> {
  List<GroceryItem> groceryItem = [];
  var _isLoading = true;
  String? _error;

  void _loadItem() async {
    final url = Uri.https(
      "flutterprep-53acb-default-rtdb.firebaseio.com",
      "shopping_list.json",
    );

    try {
      final response = await http.get(url);

// if there is no data in server or db
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // if there is any error in in server or not found
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch data. Please try again later";
        });
      }

      // converting the response body into the map list
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> _loadedItem = [];

// converting to our defined type
      for (final item in listData.entries) {
        final Category category = categories.entries
            .firstWhere((categoryItem) =>
                categoryItem.value.title == item.value["category"])
            .value;
        _loadedItem.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }

      // updating the grocery item
      setState(() {
        groceryItem = _loadedItem;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = "Some thing went wrong while loading...";
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItem();
  }

  void _addItem() async {
    final newItem = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => FormScreen()));
    if (newItem == null) {
      return;
    }

    setState(() {
      groceryItem.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    // getting the index of the item
    final index = groceryItem.indexOf(item);
    setState(() {
      // removing the item from the list
      groceryItem.remove(item);
    });

    final url = Uri.https(
      "flutterprep-53acb-default-rtdb.firebaseio.com",
      "shopping_list/${item.id}.json",
    );
    // removing the item from the database by id
    final response = await http.delete(url);

    // if anythings error comes after deleting then adding back that item in our local list
    if (response.statusCode >= 400) {
      setState(() {
        groceryItem.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        "No thing to show",
        style: TextStyle(fontSize: 18),
      ),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (groceryItem.isNotEmpty) {
      content = ListView.builder(
          itemCount: groceryItem.length,
          itemBuilder: (ctx, index) {
            return Dismissible(
              onDismissed: (direction) {
                _removeItem(groceryItem[index]);
              },
              key: Key(groceryItem[index].id),
              child: ListTile(
                title: Text(groceryItem[index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: groceryItem[index].category.color,
                ),
                trailing: Text(
                  groceryItem[index].quantity.toString(),
                ),
              ),
            );
          });
    }

    if (_error != null) {
      content = Center(
        child: Text(
          _error!,
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Groceries"),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
