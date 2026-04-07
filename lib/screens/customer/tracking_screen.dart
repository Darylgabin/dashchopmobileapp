import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TrackingScreen extends StatelessWidget {
  final String orderId;
  final Color primaryBrown = const Color(0xFF7D4427);

  const TrackingScreen({super.key, this.orderId = "#ORD-9921"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. MAP PLACEHOLDER (Will be Google Maps later)
          Container(
            color: Colors.grey.shade300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.map_pin_ellipse, size: 100, color: primaryBrown.withOpacity(0.4)),
                  const Text("Live Map Tracking UI Placeholder", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // 2. TRACKING INFO CARD
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Order $orderId", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          const Text("On the way!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: primaryBrown.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(Icons.moped, color: primaryBrown),
                      )
                    ],
                  ),
                  const Divider(height: 30),
                  
                  // Delivery Personnel Info
                  Row(
                    children: [
                      const CircleAvatar(radius: 25, backgroundColor: Color(0xFFF5F5F5), child: Icon(Icons.person, color: Colors.grey)),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("DashChop Delivery", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("ETA: 15 - 20 mins", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {}, 
                        icon: const Icon(Icons.call, color: Colors.green),
                        style: IconButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.1)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}