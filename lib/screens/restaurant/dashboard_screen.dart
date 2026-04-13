import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'delivery_screen.dart';
import 'admin_menu_screen.dart';
import '../auth/login_screen.dart';

// 📡 The Provider: Fetches orders, customer names, and food details in one shot
final dashboardProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('orders')
      .select('''
        *,
        customer:users!orders_customer_id_fkey(name),
        order_items(
          quantity,
          food_items(name)
        )
      ''')
      .inFilter('status', ['confirmed', 'on_the_way'])
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
});

class DashboardScreen extends ConsumerWidget {
  final Color primaryBrown = const Color(0xFF7D4427);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Orders",
          style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold),
        ),
        actions: [
          // 🧁 Manage Menu Button
          IconButton(
            icon: Icon(CupertinoIcons.square_grid_2x2, color: primaryBrown),
            tooltip: "Menu Manager",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminMenuScreen()),
            ),
          ),
          // 🔄 Refresh Button
          IconButton(
            icon: Icon(Icons.refresh, color: primaryBrown),
            onPressed: () => ref.invalidate(dashboardProvider),
          ),
          // 🚪 Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
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
              child: ordersAsyncValue.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: primaryBrown),
                ),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (orders) {
                  if (orders.isEmpty) {
                    return Center(
                      child: Text(
                        "No active orders right now.",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) =>
                        _buildOrderCard(context, ref, orders[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> order,
  ) {
    // 1. Safe Formatting for the ID (ORDER 001)
    final orderNum = order['order_number']?.toString() ?? '0';
    final orderDisplayId = "ORDER ${orderNum.padLeft(3, '0')}";

    // 2. Safe Customer Name extraction
    final customerData = order['customer'];
    final customerName = (customerData is Map)
        ? (customerData['name'] ?? 'Guest')
        : 'Guest';

    // 3. Safe Food Item extraction (Prevents Red Screen)
    final List? itemsList = order['order_items'] as List?;
    String foodDetails = "No items found";

    if (itemsList != null && itemsList.isNotEmpty) {
      foodDetails = itemsList
          .map((item) {
            final foodData = item['food_items'];
            final name = (foodData is Map)
                ? (foodData['name'] ?? 'Unknown')
                : 'Unknown';
            final qty = item['quantity'] ?? 0;
            return "$name (x$qty)";
          })
          .join(", ");
    }

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
              Text(
                orderDisplayId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  (order['status'] ?? 'CONFIRMED').toString().toUpperCase(),
                  style: TextStyle(
                    color: primaryBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Customer Info
          Row(
            children: [
              Icon(CupertinoIcons.person_fill, size: 16, color: primaryBrown),
              const SizedBox(width: 8),
              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 🎂 THE FOOD ITEMS LIST BOX
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Text(
              foodDetails,
              style: TextStyle(
                color: primaryBrown,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            "📍 ${order['delivery_address'] ?? 'No address'}",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${order['total_price'] ?? 0} F",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBrown,
                ),
              ),
              Row(
                children: [
                  // REJECT ACTION
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    onPressed: () =>
                        _showRejectDialog(context, ref, order['id']),
                  ),
                  const SizedBox(width: 8),
                  // DELIVER ACTION
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeliveryScreen(
                          realOrderId: order['id'],
                          shortOrderId: orderDisplayId,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Deliver",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    WidgetRef ref,
    String realOrderId,
  ) {
    String selectedReason = "Out of Stock";
    final reasons = [
      "Out of Stock",
      "Restaurant Closed",
      "Delivery Too Far",
      "Other",
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            "Reject Order?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: DropdownButton<String>(
            isExpanded: true,
            value: selectedReason,
            items: reasons
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => selectedReason = v!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client
                    .from('orders')
                    .update({
                      'status': 'rejected',
                      'rejection_reason': selectedReason,
                    })
                    .eq('id', realOrderId);

                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(dashboardProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Order Rejected"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Confirm Reject",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
