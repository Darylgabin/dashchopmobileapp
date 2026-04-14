import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; 
import '../../providers/order_provider.dart';
import 'tracking_screen.dart';

class OrderHistoryScreen extends ConsumerWidget {
  final Color primaryBrown = const Color(0xFF7D4427);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 Watching a STREAM now instead of a Future
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Order History",
          style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: historyAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: primaryBrown)),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Text(
                "No past orders yet.",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
            );
          }
          // We don't need RefreshIndicator anymore because it's live!
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, order); 
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    DateTime createdAt = DateTime.parse(order['created_at']);
    String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
    
    // We keep the sequential ID logic hidden or for navigation purposes
    String shortId = "ORDER ${order['order_number']?.toString().padLeft(3, '0') ?? '---'}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ HEADER: Price is now the main focus
              Text(
                "${order['total_price']} F",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryBrown),
              ),
              _buildStatusPill(order['status'] ?? 'confirmed'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(formattedDate, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ],
          ),
          const Divider(height: 24),
          Text(
            "📍 Address: ${order['delivery_address']}",
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          
          if (order['status'] != 'rejected' && order['status'] != 'delivered')
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackingScreen(
                          realOrderId: order['id'],
                          shortOrderId: shortId,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryBrown),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("Track Live Delivery", style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color color = Colors.orange;
    if (status == 'delivered') color = Colors.green;
    if (status == 'on_the_way') color = Colors.blue;
    if (status == 'rejected') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}