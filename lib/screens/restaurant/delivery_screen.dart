import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  final String googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> _markers = {};

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  LatLng? customerLocation;
  LatLng? adminLocation;

  StreamSubscription<Position>? _positionStream;
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

  void _updateAdminLocation(Position position) async {
    setState(() {
      adminLocation = LatLng(position.latitude, position.longitude);
      _setMapPins();
    });

    _getPolyline();

    // 📡 ALWAYS BROADCAST TO SUPABASE (With Error Catching!)
    try {
      await supabase
          .from('orders')
          .update({
            'admin_lat': position.latitude,
            'admin_lng': position.longitude,
          })
          .eq('id', widget.realOrderId);

      print(
        "✅ GPS Broadcasted Successfully: ${position.latitude}, ${position.longitude}",
      );
    } catch (error) {
      print(
        "🚨 GPS BROADCAST FAILED: $error",
      ); // 👈 This will scream if RLS blocks it!
    }
  }

  Future<void> _getPolyline() async {
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

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
          ),
        };
      });
    }
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
    _fitMapToMarkers();
  }

  Future<void> _fitMapToMarkers() async {
    if (customerLocation == null || adminLocation == null) return;
    final GoogleMapController controller = await _controller.future;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        adminLocation!.latitude < customerLocation!.latitude
            ? adminLocation!.latitude
            : customerLocation!.latitude,
        adminLocation!.longitude < customerLocation!.longitude
            ? adminLocation!.longitude
            : customerLocation!.longitude,
      ),
      northeast: LatLng(
        adminLocation!.latitude > customerLocation!.latitude
            ? adminLocation!.latitude
            : customerLocation!.latitude,
        adminLocation!.longitude > customerLocation!.longitude
            ? adminLocation!.longitude
            : customerLocation!.longitude,
      ),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
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
                  polylines: _polylines,
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller) =>
                      _controller.complete(controller),
                ),

                // 📋 CLEANED UP ACTION PANEL (Only the button remains!)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _markAsDelivered,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "MARK AS DELIVERED",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
