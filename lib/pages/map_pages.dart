// ignore_for_file: prefer_const_constructors

import 'package:first/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../providers/chat_services.dart';
import 'map_module.dart/mech_details_onmap.dart';
//import 'mechanic_details_page.dart';

class MapPage extends StatefulWidget {
  final String selectedService;
  final String serviceName;
  const MapPage(
      {super.key, required this.selectedService, required this.serviceName});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final ChatService chatService = ChatService();
  final Location locationController = Location();
  LatLng? currentposition;

  // Variable to keep track of the selected mechanic
  int? selectedMechanicIndex;

  // Scroll controller for ListView
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getLocationUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return currentposition != null
        ? Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
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
                      title: Text(widget.serviceName,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor)),
                      leading: GestureDetector(
                        child: Icon(Icons.arrow_back),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      toolbarHeight: 32,
                    ))),
            body: StreamBuilder<List<Map<String, dynamic>>>(
              stream: chatService.getMechanicsStream(widget.selectedService),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> mechanicsData = snapshot.data!;
                  if (mechanicsData.isNotEmpty) {
                    List<LatLng> mechanicLocations =
                        mechanicsData.map((mechanic) {
                      double latitude =
                          (mechanic['latitude'] as double?) ?? 0.0;
                      double longitude =
                          (mechanic['longitude'] as double?) ?? 0.0;
                      return LatLng(latitude, longitude);
                    }).toList();

                    return Stack(
                      children: [
                        GoogleMap(
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
                                  infoWindow: InfoWindow(
                                      title: 'You are currently here')),
                            for (int i = 0; i < mechanicLocations.length; i++)
                              Marker(
                                markerId: MarkerId(
                                    i.toString()), // Use the index as marker ID
                                position: mechanicLocations[i],
                                infoWindow: InfoWindow(title: 'Mechanic'),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed,
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedMechanicIndex = i;
                                  });
                                  _scrollToSelectedMechanic();
                                },
                              ),
                          },
                        ),
                        Positioned(
                          bottom: 20.0,
                          left: 20.0,
                          right: 20.0,
                          child: SizedBox(
                            height: 140.0,
                            child: ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: mechanicsData.length,
                              itemBuilder: (context, index) {
                                final mechanic = mechanicsData[index];
                                final LatLng mechanicLocation =
                                    mechanicLocations[index];
                                final double distance =
                                    Geolocator.distanceBetween(
                                          currentposition!.latitude,
                                          currentposition!.longitude,
                                          mechanicLocation.latitude,
                                          mechanicLocation.longitude,
                                        ) /
                                        1000; // Convert to kilometers
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedMechanicIndex = index;
                                    });
                                    _scrollToSelectedMechanic();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MechanicDetailsPage(
                                          mechanic: mechanic,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 200.0,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: index == selectedMechanicIndex
                                          ? Colors
                                              .blue[100] // Highlighted color
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                mechanic['name'] ??
                                                    'Mechanic Name',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              SizedBox(height: 4.0),
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundImage: NetworkImage(
                                                  mechanic['profilePic'] ??
                                                      'profilePic',
                                                ),
                                              ),
                                              SizedBox(height: 4.0),
                                              Text(
                                                '${distance.toStringAsFixed(2)} km away',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.0,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 8, 16, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                mechanic['rating'] ?? "NA",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0,
                                                    color: Colors.amber),
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }
                // Return a loading or error state widget if snapshot has no data or data is empty
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
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

  // Function to scroll to the selected mechanic
  void _scrollToSelectedMechanic() {
    if (selectedMechanicIndex != null) {
      _scrollController.animateTo(
        selectedMechanicIndex! *
            216, // Adjust this value according to your item height
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}
