// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../providers/chat_services.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final ChatService chatService = ChatService();
  final Location locationController = Location();
  LatLng? currentposition;

  @override
  void initState() {
    super.initState();
    _getLocationUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getMechanicsStream("is4WheelRepairSelected"),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> mechanicsData = snapshot.data!;
            if (mechanicsData.isNotEmpty) {
              List<LatLng> mechanicLocations = mechanicsData.map((mechanic) {
                double latitude = (mechanic['latitude'] as double?) ?? 0.0;
                double longitude = (mechanic['longitude'] as double?) ?? 0.0;
                return LatLng(latitude, longitude);
              }).toList();

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentposition!,
                  zoom: 15,
                ),
                markers: {
                  if (currentposition != null)
                    Marker(
                      markerId: const MarkerId("currentLocation"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                      position: currentposition!,
                    ),
                  for (LatLng location in mechanicLocations)
                    Marker(
                      markerId: MarkerId(location.toString()),
                      position: location,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                },
                polylines: {
                  if (currentposition != null)
                    Polyline(
                      polylineId: const PolylineId("directions"),
                      points: [mechanicLocations.first, currentposition!],
                      color: Colors.blue,
                      width: 3,
                    ),
                },
              );
            }
          }
          // Return a loading or error state widget if snapshot has no data or data is empty
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
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
            currentposition =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
          });
        }
      });
    }
  }
}
