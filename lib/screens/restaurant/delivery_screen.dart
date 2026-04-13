import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryScreen extends StatefulWidget {
  final String realOrderId;
  final String shortOrderId;

  const DeliveryScreen({required this.realOrderId, required this.shortOrderId});

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  bool _isSharingLocation = false;
  bool _isLoading = false;
  final Color primaryBrown = const Color(0xFF7D4427);

  @override
  void initState() {
    super.initState();
    _setOrderToOnTheWay();
  }

  // 1. Automatically update status when this screen opens
  Future<void> _setOrderToOnTheWay() async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': 'on_the_way'})
          .eq('id', widget.realOrderId);
    } catch (e) {
      print("Failed to update status: $e");
    }
  }

  // 2. Mark as Delivered and close screen
  Future<void> _markAsDelivered() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': 'delivered'})
          .eq('id', widget.realOrderId);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order Marked as Delivered! ✅", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Go back to dashboard
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delivering ${widget.shortOrderId}"),
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // MAP PLACEHOLDER
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.map_pin_ellipse, size: 80, color: primaryBrown.withOpacity(0.3)),
                    const SizedBox(height: 10),
                    const Text("Google Maps View Placeholder", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),

          // CONTROL PANEL
          Container(
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Share My Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Switch(
                      value: _isSharingLocation,
                      activeColor: primaryBrown,
                      onChanged: (val) {
                        setState(() => _isSharingLocation = val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(val ? "GPS Tracking Started 📡" : "GPS Tracking Paused")),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _markAsDelivered,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("MARK AS DELIVERED", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}