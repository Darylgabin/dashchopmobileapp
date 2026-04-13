import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMenuScreen extends StatefulWidget {
  @override
  _AdminMenuScreenState createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final Color primaryBrown = const Color(0xFF7D4427);
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase.from('food_items').select().order('created_at');
      setState(() {
        _menuItems = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching menu: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showItemDialog({Map<String, dynamic>? existingItem}) {
    final isEditing = existingItem != null;
    final nameCtrl = TextEditingController(text: isEditing ? existingItem['name'] : '');
    final categoryCtrl = TextEditingController(text: isEditing ? existingItem['category'] : 'Cakes');
    final priceCtrl = TextEditingController(text: isEditing ? existingItem['price'].toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? "Edit Item" : "Add New Item", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Food Name (e.g., Apple Pie)")),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: "Category (Cakes or Pies)")),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price (FCFA)")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            if (isEditing)
              TextButton(
                onPressed: () async {
                  try {
                    await supabase.from('food_items').delete().eq('id', existingItem['id']);
                    if (context.mounted) {
                      Navigator.pop(context);
                      _fetchMenu();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item Deleted"), backgroundColor: Colors.red));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete Failed: $e")));
                  }
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: () async {
                final price = int.tryParse(priceCtrl.text) ?? 0;
                if (nameCtrl.text.isEmpty || price == 0) return;

                try {
                  if (isEditing) {
                    await supabase.from('food_items').update({
                      'name': nameCtrl.text,
                      'category': categoryCtrl.text,
                      'price': price,
                    }).eq('id', existingItem['id']);
                  } else {
                    await supabase.from('food_items').insert({
                      'name': nameCtrl.text,
                      'category': categoryCtrl.text,
                      'price': price,
                      'restaurant_id': supabase.auth.currentUser!.id,
                    });
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    _fetchMenu();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? "Updated!" : "Added!"), backgroundColor: Colors.green));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save Failed: $e")));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryBrown),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Menu"),
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        backgroundColor: primaryBrown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryBrown))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.fastfood, color: Colors.orange),
                  title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${item['category']} • ${item['price']} F"),
                  trailing: const Icon(Icons.edit, color: Colors.grey),
                  onTap: () => _showItemDialog(existingItem: item),
                ),
              );
            },
          ),
    );
  }
}