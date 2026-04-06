import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> restaurants = [
    {
      "name": "Pizza Palace",
      "description": "Best pizzas in town",
      "image": "https://via.placeholder.com/150"
    },
    {
      "name": "Burger Hub",
      "description": "Juicy burgers & fries",
      "image": "https://via.placeholder.com/150"
    },
    {
      "name": "African Delights",
      "description": "Local traditional meals",
      "image": "https://via.placeholder.com/150"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DashChop"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];

          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    restaurant["image"],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant["name"],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        restaurant["description"],
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // next step: open menu
                        },
                        child: Text("View Menu"),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}