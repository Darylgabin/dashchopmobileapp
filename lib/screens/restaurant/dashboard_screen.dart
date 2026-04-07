import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'delivery_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Color primaryBrown = const Color(0xFF7D4427);

  // Mock orders for the Dashboard
  final List<Map<String, dynamic>> activeOrders = [
    {
      "id": "#ORD-9921",
      "customer": "Jeff",
      "address": "Bastos, Yaoundé",
      "items": "Plain Cake, Meat Pie (x2)",
      "total": "3900 F",
      "status": "New",
    },
    {
      "id": "#ORD-9925",
      "customer": "Merveille",
      "address": "Mvan junction, Yaoundé",
      "items": "Mega Meat Pie (Cheese)",
      "total": "10000 F",
      "status": "Preparing",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Restaurant Dashboard",
          style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: primaryBrown),
            onPressed: () => Navigator.pop(context), // Temporary logout
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Active Orders",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: activeOrders.length,
                itemBuilder: (context, index) {
                  final order = activeOrders[index];
                  return _buildOrderCard(context, order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order['id'], style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                order['status'],
                style: TextStyle(
                  color: order['status'] == "New" ? Colors.orange : primaryBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text("Customer: ${order['customer']}", style: const TextStyle(fontSize: 16)),
          Text("Address: ${order['address']}", style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text("Items: ${order['items']}", style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: ${order['total']}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBrown),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DeliveryScreen(orderId: order['id'])),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBrown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Start Delivery", style: TextStyle(color: Colors.white)),
              )
            ],
          )
        ],
      ),
    );
  }
}