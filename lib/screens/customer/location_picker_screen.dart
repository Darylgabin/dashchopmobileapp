import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final Color primaryBrown = const Color(0xFF7D4427);

  // � Replace the old hardcoded key with this!
  final String _googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  LatLng _cameraCenter = const LatLng(3.8480, 11.5021); // Yaoundé
  bool _isMoving = false;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // 💡 THE SEARCH LOGIC (Geocoding)
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    // Show a quick loading snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Searching...")));

    // Call Google's Geocoding API (forces the search to prioritize Yaoundé, Cameroon)
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query + ', Yaounde, Cameroon')}&key=$_googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        final newTarget = LatLng(location['lat'], location['lng']);

        // Fly the camera to the searched location!
        final controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(newTarget, 16));

        setState(() => _cameraCenter = newTarget);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location not found! Try being more specific."),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Search failed. Check your connection.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _cameraCenter,
              zoom: 15,
            ),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onCameraMoveStarted: () => setState(() => _isMoving = true),
            onCameraMove: (position) {
              _cameraCenter = position.target;
            },
            onCameraIdle: () => setState(() => _isMoving = false),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(0, _isMoving ? -20 : 0, 0),
                child: const Icon(
                  CupertinoIcons.location_solid,
                  size: 50,
                  color: Colors.red,
                ),
              ),
            ),
          ),

          // 🔍 THE SEARCH BAR
          Positioned(
            top: 60,
            left: 60,
            right: 20,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search your location...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: primaryBrown),
                  ),
                  onSubmitted: (value) =>
                      _searchLocation(value), // Trigger the search!
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _cameraCenter);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBrown,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 10,
              ),
              child: const Text(
                "Deliver to this exact spot",
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
}
