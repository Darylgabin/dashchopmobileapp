import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  final Color primaryBrown = const Color(0xFF7D4427);

  // Mock data for UI purposes
  final List<Map<String, dynamic>> pastOrders = [
    {
      "id": "#ORD-8943",
      "date": "12 April 2026, 14:30",
      "items": "Mega Meat Pie, Plain Cake",
      "total": "14000 F",
      "status": "Delivered",
    },
    {
      "id": "#ORD-8910",
      "date": "10 April 2026, 09:15",
      "items": "Yoghurt Cake, Natural Pancake (x2)",
      "total": "5700 F",
      "status": "Delivered",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Order History",
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: pastOrders.isEmpty
          ? Center(
              child: Text(
                "No past orders yet.",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: pastOrders.length,
              itemBuilder: (context, index) {
                final order = pastOrders[index];
                return _buildOrderCard(order);
              },
            ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Order ID and Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order["id"],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Delivered",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Date
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                order["date"],
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          
          // Items
          Text(
            order["items"],
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const SizedBox(height: 12),
          
          // Bottom Row: Total and Details Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: ${order["total"]}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryBrown,
                ),
              ),
          
            ],
          ),
        ],
      ),
    );
  }
}