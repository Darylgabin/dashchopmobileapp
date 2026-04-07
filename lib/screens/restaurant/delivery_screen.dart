import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DeliveryScreen extends StatefulWidget {
  final String orderId;
  const DeliveryScreen({required this.orderId});

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  bool _isSharingLocation = false;
  final Color primaryBrown = const Color(0xFF7D4427);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delivering ${widget.orderId}"),
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
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Share My Location",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: _isSharingLocation,
                      activeColor: primaryBrown,
                      onChanged: (val) {
                        setState(() => _isSharingLocation = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Order Marked as Delivered!")),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      "MARK AS DELIVERED",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
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