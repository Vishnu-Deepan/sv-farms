import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  final PageController pageController;
  final Function(LatLng) onLocationSelected; // Callback to pass the selected location

  MapPage(this.pageController, this.onLocationSelected);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late LatLng deliveryLocation;
  bool isLocationSelected = false;
  bool isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // Check if location permission is granted
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Request permission if not granted
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      setState(() {
        isPermissionGranted = true;
      });
      _getCurrentLocation();
    } else {
      // If permission is not granted, show an alert
      setState(() {
        isPermissionGranted = false;
      });
      _showPermissionAlert();
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    if (isPermissionGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        deliveryLocation = LatLng(position.latitude, position.longitude);
      });
    }
  }

  // Show permission alert if location permission is denied
  void _showPermissionAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Permission Required"),
        content: Text(
            "Please enable location permissions to proceed with location selection."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  // Show confirmation dialog after location selection
  void _showLocationConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Location"),
        content: Text(
            "Do you want to select this location: (${deliveryLocation.latitude}, ${deliveryLocation.longitude})?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Use the callback to pass the selected location back
              widget.onLocationSelected(deliveryLocation);
              widget.pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.ease,
              );
              Navigator.pop(context); // Close confirmation dialog
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isPermissionGranted
        ? Column(
      children: [
        Text("Select Delivery Location", style: TextStyle(fontSize: 18)),
        Container(
          height: 400,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: deliveryLocation,
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                setState(() {
                  deliveryLocation = point;
                  isLocationSelected = true;
                });

                // Show location confirmation dialog
                _showLocationConfirmation();
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [
                  if (isLocationSelected)
                    Marker(
                      point: deliveryLocation,
                      width: 80,
                      height: 80,
                      child: Icon(Icons.location_pin,
                          color: Colors.red, size: 40),
                    ),
                ],
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (isLocationSelected) {
              widget.pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease);
            } else {
              _showLocationConfirmation();
            }
          },
          child: Text('Next'),
        ),
      ],
    )
        : Center(child: CircularProgressIndicator());
  }
}
