import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/dummy_data.dart';
import '../../widgets/food_card.dart';

class MenuScreen extends StatelessWidget {
  final Color primaryBrown = const Color(0xFF7D4427);

  @override
  Widget build(BuildContext context) {
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
                  // Logic for filtering will go here later with Riverpod
                },
              ),
            ),
          ),

          // 🍽️ Piled Plates List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: dummyMenu.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: FoodCard(food: dummyMenu[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}