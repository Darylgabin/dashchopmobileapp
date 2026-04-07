import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../models/dummy_data.dart';
import '../../widgets/food_card.dart';

// A simple Riverpod state to hold whatever the user types in the search bar
final searchQueryProvider = StateProvider<String>((ref) => '');

class MenuScreen extends ConsumerWidget {
  final Color primaryBrown = const Color(0xFF7D4427);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to the search query live
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

    // 2. Filter the dummyMenu based on the search query
    final filteredMenu = dummyMenu.where((food) {
      return food.name.toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "DashChop Menu",
          style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for cakes or pies...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(CupertinoIcons.search, color: primaryBrown),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (value) {
                  // Update the Riverpod state whenever the user types
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
            ),
          ),

          // 🍽️ Piled Plates List
          Expanded(
            child: filteredMenu.isEmpty
                ? Center(
                    child: Text(
                      "No items found for '$searchQuery'",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredMenu.length, // Use the filtered list!
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: FoodCard(food: filteredMenu[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
