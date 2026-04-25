import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // 👈 NEW

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
    
    // Image Upload Variables
    File? selectedImage;
    String? existingImageUrl = isEditing ? existingItem['image_url'] : null;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // We use StatefulBuilder so the dialog can update when an image is picked
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? "Edit Item" : "Add New Item", style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 📸 IMAGE PICKER UI
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                        if (image != null) {
                          setDialogState(() => selectedImage = File(image.path));
                        }
                      },
                      child: Container(
                        height: 120, width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(15),
                          image: selectedImage != null 
                            ? DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover)
                            : (existingImageUrl != null 
                                ? DecorationImage(image: NetworkImage(existingImageUrl!), fit: BoxFit.cover) 
                                : null),
                        ),
                        child: selectedImage == null && existingImageUrl == null
                            ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade500)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Tap to select image", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 10),

                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Food Name (e.g., Apple Pie)")),
                    TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: "Category (Cakes or Pies)")),
                    TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price (FCFA)")),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(context), 
                  child: const Text("Cancel")
                ),
                
                if (isEditing)
                  TextButton(
                    onPressed: isUploading ? null : () async {
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
                  onPressed: isUploading ? null : () async {
                    final price = int.tryParse(priceCtrl.text) ?? 0;
                    if (nameCtrl.text.isEmpty || price == 0) return;

                    setDialogState(() => isUploading = true); // Show loading spinner

                    try {
                      String? finalImageUrl = existingImageUrl;

                      // ☁️ UPLOAD TO SUPABASE IF NEW IMAGE SELECTED
                      if (selectedImage != null) {
                        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
                        await supabase.storage.from('menu_images').upload(fileName, selectedImage!);
                        finalImageUrl = supabase.storage.from('menu_images').getPublicUrl(fileName);
                      }

                      // 💾 SAVE TO DATABASE
                      if (isEditing) {
                        await supabase.from('food_items').update({
                          'name': nameCtrl.text,
                          'category': categoryCtrl.text,
                          'price': price,
                          'image_url': finalImageUrl, // 👈 Save the link
                        }).eq('id', existingItem['id']);
                      } else {
                        await supabase.from('food_items').insert({
                          'name': nameCtrl.text,
                          'category': categoryCtrl.text,
                          'price': price,
                          'restaurant_id': supabase.auth.currentUser!.id,
                          'image_url': finalImageUrl, // 👈 Save the link
                        });
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        _fetchMenu();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? "Updated!" : "Added!"), backgroundColor: Colors.green));
                      }
                    } catch (e) {
                      setDialogState(() => isUploading = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save Failed: $e")));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBrown),
                  child: isUploading 
                    ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
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
              final String? imageUrl = item['image_url'];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  // 📸 SHOW TINY IMAGE IN THE LIST
                  leading: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
                    ),
                    child: imageUrl == null ? const Icon(Icons.fastfood, color: Colors.orange) : null,
                  ),
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