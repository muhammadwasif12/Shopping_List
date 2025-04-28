import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shopping_list/data/categories.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'shopping-list-26c6a-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch Data. Please try again later!";
        });
      }
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category =
            categories.entries
                .firstWhere(
                  (catItem) => catItem.value.title == item.value['category'],
                )
                .value;

        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = "Something went wrong. Please try again later!";
      });
    }
  }

  void _newItem() async {
    final newItem = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const NewItem(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0); // right se left
          var end = Offset.zero;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  Future<bool?> _showDeleteDialog(BuildContext context, GroceryItem item) {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Confirm Delete', style: TextStyle(color: Colors.red)),
            content: Text(
              'Are you sure you want to remove "${item.name}" from your list?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false), // 'No'
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true), // 'Yes'
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Yes'),
              ),
            ],
          ),
    );
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    // Immediately show SnackBar first
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackBar = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item deleted'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () async {
            setState(() {
              _groceryItems.insert(index, item);
            });
            final undoUrl = Uri.https(
              'shopping-list-26c6a-default-rtdb.firebaseio.com',
              'shopping-list/${item.id}.json',
            );
            await http.put(
              undoUrl,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'name': item.name,
                'quantity': item.quantity,
                'category': item.category.title,
              }),
            );
          },
        ),
      ),
    );

    // Now background mein firebase delete karo
    final url = Uri.https(
      'shopping-list-26c6a-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // Error aya to undo immediately
      snackBar.close();
      setState(() {
        _groceryItems.insert(index, item);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete! Item restored.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(child: Text("No Items Added Yet!"));

    if (_isLoading) {
      content = Center(
        child: CircularProgressIndicator(backgroundColor: Colors.white),
      );
    } else if (_error != null) {
      content = Center(child: Text(_error!));
    } else if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        key: ValueKey(_groceryItems.length),
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(_groceryItems[index].id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              final shouldDelete = await _showDeleteDialog(
                context,
                _groceryItems[index],
              );
              return shouldDelete; // true karega to dismiss hoga, false karega to cancel
            },
            onDismissed: (direction) {
              _removeItem(_groceryItems[index]);
            },
            background: Container(
              color: Colors.red,
              padding: EdgeInsets.all(12),
              alignment: Alignment.centerRight,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: Container(
                width: 24,
                height: 24,
                color: _groceryItems[index].category.color,
              ),
              trailing: Text(_groceryItems[index].quantity.toString()),
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),

        actions: [IconButton(onPressed: _newItem, icon: Icon(Icons.add))],
      ),

      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 700),
        child: content,
      ),
    );
  }
}
