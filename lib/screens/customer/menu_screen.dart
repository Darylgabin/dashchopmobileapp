import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../models/food_model.dart';
import '../../widgets/food_card.dart';
import '../../providers/menu_provider.dart'; // Add this import

final searchQueryProvider = StateProvider<String>((ref) => '');

class MenuScreen extends ConsumerWidget {
  final Color primaryBrown = const Color(0xFF7D4427);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    
    // 1. We watch the LIVE cloud data provider instead of dummy data
    final menuAsyncValue = ref.watch(menuProvider); 

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
          // 🔍 Search Bar Section (Unchanged)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
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
                onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
              ),
            ),
          ),

          // 🍽️ Piled Plates List (Now with Cloud Logic!)
          Expanded(
            child: menuAsyncValue.when(
              // STATE 1: LOADING
              loading: () => Center(child: CircularProgressIndicator(color: primaryBrown)),
              
              // STATE 2: ERROR (If internet drops or Supabase fails)
              error: (err, stack) => Center(child: Text('Error loading menu: $err')),
              
              // STATE 3: SUCCESS (Data fetched!)
              data: (menuItems) {
                // Apply the search filter to the live data
                final filteredMenu = menuItems.where((food) {
                  return food.name.toLowerCase().contains(searchQuery);
                }).toList();

                if (filteredMenu.isEmpty) {
                  return Center(
                    child: Text("No items found for '$searchQuery'", style: TextStyle(color: Colors.grey.shade500)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredMenu.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: FoodCard(food: filteredMenu[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}