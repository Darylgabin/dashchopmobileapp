import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class TrackingScreen extends StatefulWidget {
  final String realOrderId;
  final String shortOrderId;

  const TrackingScreen({
    required this.realOrderId,
    required this.shortOrderId,
    Key? key,
  }) : super(key: key);

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final Color primaryBrown = const Color(0xFF7D4427);
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _orderData;

  // Yaoundé Coordinates
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(3.8480, 11.5021),
    zoom: 14.4746,
  );

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    _subscribeToOrder();
  }

  void _subscribeToOrder() {
    supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', widget.realOrderId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty && mounted) {
            setState(() => _orderData = data.first);
          }
        });
  }

  // 💡 THE POPUP LOGIC
  void _showStatusBottomSheet(BuildContext context, String status) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wraps tightly around the content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small drag handle at the top
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                "Delivery Status",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              _buildTrackStep(
                icon: CupertinoIcons.checkmark_circle_fill,
                title: "Order Confirmed",
                isDone: true,
              ),
              _buildTrackStep(
                icon: CupertinoIcons.cube_box_fill,
                title: "On the Way",
                isDone: status == 'on_the_way' || status == 'delivered',
                isActive: status == 'on_the_way',
              ),
              _buildTrackStep(
                icon: CupertinoIcons.house_fill,
                title: "Delivered",
                isLast: true,
                isDone: status == 'delivered',
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_orderData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: primaryBrown)),
      );
    }

    final String status = _orderData!['status'] ?? 'confirmed';

    return Scaffold(
      extendBodyBehindAppBar:
          true, // 👈 Allows the map to flow behind the AppBar!
      appBar: AppBar(
        title: Text("Track ${widget.shortOrderId}"),
        backgroundColor: Colors.white.withOpacity(0.9), // Slightly see-through
        foregroundColor: primaryBrown,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        // 👈 Stack puts the map on the bottom layer
        children: [
          // 🗺️ FULL SCREEN MAP
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          // STATUS PILL
          Positioned(
            top: 110, // Pushed down to clear the AppBar
            right: 20,
            child: _buildStatusPill(status),
          ),

          // 👆 FLOATING POPUP BUTTON
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => _showStatusBottomSheet(context, status),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBrown,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 10,
              ),
              child: const Text(
                "View Delivery Status",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackStep({
    required IconData icon,
    required String title,
    bool isLast = false,
    bool isDone = false,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Icon(
              icon,
              color: isDone
                  ? Colors.green
                  : (isActive ? primaryBrown : Colors.grey.shade300),
              size: 28,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isDone ? Colors.green : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 20),
        Text(
          title,
          style: TextStyle(
            fontWeight: isDone || isActive
                ? FontWeight.bold
                : FontWeight.normal,
            color: isDone
                ? Colors.green
                : (isActive ? primaryBrown : Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String status) {
    Color color = Colors.orange;
    if (status == 'delivered') color = Colors.green;
    if (status == 'on_the_way') color = Colors.blue;
    if (status == 'rejected') color = Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
