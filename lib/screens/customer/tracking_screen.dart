import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; 
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

  final String googleApiKey = "AIzaSyAXRWa8f_IrCmWQYWGRBisln6u48KpEul4";

  Map<String, dynamic>? _orderData;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  Set<Marker> _markers = {};

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  LatLng? customerLocation;
  LatLng? adminLocation;

  @override
  void initState() {
    super.initState();
    // 💡 FIX 1: API Key goes here!
    polylinePoints = PolylinePoints(apiKey: googleApiKey); 
    _subscribeToOrder();
  }

  void _subscribeToOrder() {
    supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', widget.realOrderId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty && mounted) {
            setState(() {
              _orderData = data.first;

              if (_orderData!['delivery_lat'] != null) {
                customerLocation = LatLng(
                  (_orderData!['delivery_lat'] as num).toDouble(),
                  (_orderData!['delivery_lng'] as num).toDouble(),
                );
              }

              if (_orderData!['admin_lat'] != null) {
                adminLocation = LatLng(
                  (_orderData!['admin_lat'] as num).toDouble(),
                  (_orderData!['admin_lng'] as num).toDouble(),
                );
              }

              _setMapPins();
              _getPolyline(); 
            });
          }
        });
  }

  void _getPolyline() async {
    if (adminLocation == null || customerLocation == null) return;

    // 💡 FIX 2: No API key passed here!
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(adminLocation!.latitude, adminLocation!.longitude),
        destination: PointLatLng(customerLocation!.latitude, customerLocation!.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
          )
        };
      });
    }
  }

  void _setMapPins() {
    Set<Marker> newMarkers = {};
    if (adminLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('admin'),
          position: adminLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'Driver Location'),
        ),
      );
    }
    if (customerLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: customerLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Your House'),
        ),
      );
    }
    setState(() => _markers = newMarkers);
    _fitMapToMarkers(); 
  }

  Future<void> _fitMapToMarkers() async {
    if (customerLocation == null || adminLocation == null) return;
    final GoogleMapController controller = await _controller.future;
    
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        adminLocation!.latitude < customerLocation!.latitude ? adminLocation!.latitude : customerLocation!.latitude,
        adminLocation!.longitude < customerLocation!.longitude ? adminLocation!.longitude : customerLocation!.longitude,
      ),
      northeast: LatLng(
        adminLocation!.latitude > customerLocation!.latitude ? adminLocation!.latitude : customerLocation!.latitude,
        adminLocation!.longitude > customerLocation!.longitude ? adminLocation!.longitude : customerLocation!.longitude,
      ),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  @override
  Widget build(BuildContext context) {
    if (_orderData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final String status = _orderData!['status'] ?? 'confirmed';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Track ${widget.shortOrderId}"),
        backgroundColor: Colors.white.withOpacity(0.9),
        foregroundColor: primaryBrown,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(3.8480, 11.5021),
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines, 
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) => _controller.complete(controller),
          ),
          Positioned(top: 110, right: 20, child: _buildStatusPill(status)),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => _showStatusBottomSheet(context, status),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBrown, 
                padding: const EdgeInsets.symmetric(vertical: 16), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              child: const Text("View Delivery Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)]),
      child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  void _showStatusBottomSheet(BuildContext context, String status) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 5, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const Text("Delivery Status", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              _buildTrackStep(icon: CupertinoIcons.checkmark_circle_fill, title: "Order Confirmed", isDone: true),
              _buildTrackStep(icon: CupertinoIcons.cube_box_fill, title: "On the Way", isDone: status == 'on_the_way' || status == 'delivered', isActive: status == 'on_the_way'),
              _buildTrackStep(icon: CupertinoIcons.house_fill, title: "Delivered", isLast: true, isDone: status == 'delivered'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackStep({required IconData icon, required String title, bool isLast = false, bool isDone = false, bool isActive = false}) {
    return Row(
      children: [
        Column(
          children: [
            Icon(icon, color: isDone ? Colors.green : (isActive ? primaryBrown : Colors.grey.shade300), size: 28),
            if (!isLast) Container(width: 2, height: 30, color: isDone ? Colors.green : Colors.grey.shade200),
          ],
        ),
        const SizedBox(width: 20),
        Text(title, style: TextStyle(fontWeight: isDone || isActive ? FontWeight.bold : FontWeight.normal, color: isDone ? Colors.green : (isActive ? primaryBrown : Colors.grey.shade400))),
      ],
    );
  }
}