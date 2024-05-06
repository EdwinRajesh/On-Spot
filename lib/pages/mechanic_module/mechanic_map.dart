import 'package:first/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';

import '../../providers/chat_services.dart';

class MechanicMap extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MechanicMap({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<MechanicMap> createState() => _MechanicMapState();
}

class _MechanicMapState extends State<MechanicMap> {
  final ChatService chatService = ChatService();
  final Location locationController = Location();
  LatLng? collegePosition;
  LatLng? currentPosition;
  List<LatLng> polylineCoordinates = [];
  GoogleMapController? mapController;
  String? distanceText = '';
  // Variable to keep track of the selected mechanic
  int? selectedMechanicIndex;

  @override
  void initState() {
    super.initState();
    _getLocationUpdate();
    collegePosition = LatLng(widget.latitude, widget.longitude);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(38),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Shadow color
                spreadRadius: 2, // Spread radius
                blurRadius: 4, // Blur radius
                offset: Offset(0, 2), // Offset in the y direction
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: secondaryColor,
            title: Text(
              'Get to User',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            leading: GestureDetector(
              child: Icon(
                Icons.arrow_back,
                color: primaryColor,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            toolbarHeight: 32,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentPosition!,
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId("college"),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRose,
                ),
                position: collegePosition!,
              ),
              if (currentPosition != null)
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  position: currentPosition!,
                ),
            },
            polylines: {
              if (polylineCoordinates.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId("directions"),
                  points: polylineCoordinates,
                  color: Colors.blue,
                  width: 5,
                  geodesic: true, // Improve polyline accuracy
                ),
            },
          ),
          Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Distance: $distanceText',
                      style: TextStyle(
                          color: primaryColor, // Olive green color
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ))
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     mapController?.animateCamera(
      //       CameraUpdate.newLatLngBounds(
      //         _createBounds(collegePosition!, currentPosition!),
      //         100,
      //       ),
      //     );
      //   },
      //   child: const Icon(Icons.zoom_out_map),
      // ),
    );
  }

  Future<void> _getLocationUpdate() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
    }

    if (permissionGranted == PermissionStatus.granted) {
      locationController.onLocationChanged
          .listen((LocationData currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          setState(() {
            currentPosition =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
            _getPolyline();
          });
        }
      });
    }
  }

  Future<void> _getPolyline() async {
    if (currentPosition == null) return; // Ensure currentPosition is not null
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${currentPosition!.latitude},${currentPosition!.longitude}&destination=${collegePosition!.latitude},${collegePosition!.longitude}&key=AIzaSyDyUDNLsdECIrWJLGW980zwr5YrgZoSOko";
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      if (data["status"] == "OK") {
        List steps = data["routes"][0]["legs"][0]["steps"];
        distanceText = data["routes"][0]["legs"][0]["distance"]["text"];

        polylineCoordinates.clear();
        for (var step in steps) {
          List<LatLng> points = _decodePolyline(step["polyline"]["points"]);
          polylineCoordinates.addAll(points);
        }

        setState(() {
          // Update the polyline to show the new route
        });
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;
      poly.add(LatLng(latitude, longitude));
    }
    return poly;
  }

  LatLngBounds _createBounds(LatLng southwest, LatLng northeast) {
    return LatLngBounds(
      southwest: LatLng(
        southwest.latitude <= northeast.latitude
            ? southwest.latitude
            : northeast.latitude,
        southwest.longitude <= northeast.longitude
            ? southwest.longitude
            : northeast.longitude,
      ),
      northeast: LatLng(
        southwest.latitude > northeast.latitude
            ? southwest.latitude
            : northeast.latitude,
        southwest.longitude > northeast.longitude
            ? southwest.longitude
            : northeast.longitude,
      ),
    );
  }
}
