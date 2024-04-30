// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({Key? key}) : super(key: key);

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   final Location locationcontroller = Location();
//   static const LatLng collegeLocation = LatLng(9.726698, 76.726193);
//   LatLng? currentposition;

//   @override
//   void initState() {
//     super.initState();
//     _getLocationUpdate();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: collegeLocation,
//           zoom: 15,
//         ),
//         markers: {
//           Marker(
//             markerId: const MarkerId("college"),
//             icon: BitmapDescriptor.defaultMarker,
//             position: collegeLocation,
//           ),
//           if (currentposition != null)
//             Marker(
//               markerId: const MarkerId("currentLocation"),
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueGreen),
//               position: currentposition!,
//             ),
//         },
//         polylines: {
//           if (currentposition != null)
//             Polyline(
//               polylineId: const PolylineId("directions"),
//               points: [collegeLocation, currentposition!],
//               color: Colors.blue,
//               width: 3,
//             ),
//         },
//       ),
//     );
//   }

//   Future<void> _getLocationUpdate() async {
//     bool _serviceenabled;
//     PermissionStatus permissionGranted;

//     _serviceenabled = await locationcontroller.serviceEnabled();
//     if (!_serviceenabled) {
//       _serviceenabled = await locationcontroller.requestService();
//     }

//     permissionGranted = await locationcontroller.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await locationcontroller.requestPermission();
//     }

//     if (permissionGranted == PermissionStatus.granted) {
//       locationcontroller.onLocationChanged
//           .listen((LocationData currentLocation) {
//         if (currentLocation.latitude != null &&
//             currentLocation.longitude != null) {
//           setState(() {
//             currentposition =
//                 LatLng(currentLocation.latitude!, currentLocation.longitude!);
//           });
//         }
//       });
//     }
//   }
// }
