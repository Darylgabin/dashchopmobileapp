import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // 👈 NEW
import 'dart:async';

class DeliveryScreen extends StatefulWidget {
  final String realOrderId;
  final String shortOrderId;

  const DeliveryScreen({
    required this.realOrderId,
    required this.shortOrderId,
    Key? key,
  }) : super(key: key);

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final Color primaryBrown = const Color(0xFF7D4427);
  final supabase = Supabase.instance.client;

  // 🚨 PASTE YOUR API KEY HERE
  final String googleApiKey = "AIzaSyAXRWa8f_IrCmWQYWGRBisln6u48KpEul4";

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> _markers = {};

  // 🛣️ Polyline variables
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  LatLng? customerLocation;
  LatLng? adminLocation;

  StreamSubscription<Position>? _positionStream;
  bool _shareLocation = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints(apiKey: googleApiKey);
    _fetchOrderCoordinates();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrderCoordinates() async {
    final response = await supabase
        .from('orders')
        .select('delivery_lat, delivery_lng')
        .eq('id', widget.realOrderId)
        .single();
    if (response['delivery_lat'] != null && response['delivery_lng'] != null) {
      customerLocation = LatLng(
        (response['delivery_lat'] as num).toDouble(),
        (response['delivery_lng'] as num).toDouble(),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position initialPosition = await Geolocator.getCurrentPosition();
    _updateAdminLocation(initialPosition);

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 15,
          ),
        ).listen((Position position) {
          _updateAdminLocation(position);
        });
  }

  void _updateAdminLocation(Position position) {
    setState(() {
      adminLocation = LatLng(position.latitude, position.longitude);
      _setMapPins();
    });

    // Get the blue line route whenever the admin moves
    _getPolyline();

    if (_shareLocation) {
      supabase
          .from('orders')
          .update({
            'admin_lat': position.latitude,
            'admin_lng': position.longitude,
          })
          .eq('id', widget.realOrderId);
    }
  }

  // 💡 THE BLUE LINE LOGIC
  void _getPolyline() async {
    if (adminLocation == null || customerLocation == null) return;

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(adminLocation!.latitude, adminLocation!.longitude),
        destination: PointLatLng(
          customerLocation!.latitude,
          customerLocation!.longitude,
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue, // 👈 THE BLUE LINE
          points: polylineCoordinates,
          width: 5,
        ),
      );
    });
  }

  void _setMapPins() {
    _markers.clear();
    if (adminLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('admin'),
          position: adminLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }
    if (customerLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: customerLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }
  }

  Future<void> _markAsDelivered() async {
    await supabase
        .from('orders')
        .update({'status': 'delivered'})
        .eq('id', widget.realOrderId);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delivering ${widget.shortOrderId}"),
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBrown))
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(3.8480, 11.5021),
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines, // 👈 ADDED THIS
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller) =>
                      _controller.complete(controller),
                ),
                // Action panel remains the same...
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Share My Location",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Switch(
                              value: _shareLocation,
                              activeColor: primaryBrown,
                              onChanged: (val) =>
                                  setState(() => _shareLocation = val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _markAsDelivered,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "MARK AS DELIVERED",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
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
