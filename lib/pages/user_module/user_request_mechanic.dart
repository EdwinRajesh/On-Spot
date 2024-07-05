import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../models/car_model.dart';
import '../../providers/chat_services.dart';
import '../../utils/secondary.dart';
import '../../utils/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserRequestMechanic extends StatefulWidget {
  final CarModel car;
  final Map<String, dynamic> mechanic;

  const UserRequestMechanic({required this.car, required this.mechanic});

  @override
  State<UserRequestMechanic> createState() => _UserRequestMechanicState();
}

class _UserRequestMechanicState extends State<UserRequestMechanic> {
  String problemDescription = '';
  // Hardcoded device token
  final String deviceToken = 'eb1u4VLfQZmxF6GlFzVO3q:APA91bHCMPw5vudJm8jsyq6WBAG5yTU2BLPNYzMPdlupaPVctQMP8knq1zUycWEDJdyRE8STMe42Z-c1ENi5W4RHSRsk7MqkbFREkN0oesf0pFt48AC9AFAuJaKIKnedvn_I2TmVbegZ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Mechanic'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Describe the problem with the vehicle:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextFormField(
                  maxLines: 4,
                  onChanged: (value) {
                    setState(() {
                      problemDescription = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter problem description...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: widget.car.carPictures.isNotEmpty
                      ? Image.network(
                          widget.car.carPictures[0],
                          width: 100,
                          height: 320,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.car_repair),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.car.manufacture,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.car.model,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text('Year: ${widget.car.year}',
                          style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          Icon(Icons.local_gas_station),
                          Text(widget.car.fuel!),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14),
                SecondaryButton(
                  text: 'Send Message',
                  onPressed: () async {
                    try {
                      LatLng? position = await _getLocationUpdate();
                      ChatService chatService = ChatService();
                      await chatService.sendServiceRequest(
                        mechanicId: widget.mechanic['uid'],
                        carName: widget.car.model,
                        picture: widget.car.carPictures[0],
                        carId: widget.car.uid!,
                        problemDescription: problemDescription,
                        year: widget.car.year!,
                        fuel: widget.car.fuel!,
                        latitude: position?.latitude ?? 0.0,
                        longitude: position?.longitude ?? 0.0,
                      );

                      // Send notification to the device
                      await sendNotificationToDevice(
                        deviceToken,
                        'ON-SPOT MECHANIC',
                        'Need Assistance!',
                      );

                      showSnackBar(context, "Sent message and notification");

                      Navigator.pop(context);
                    } catch (error) {
                      showSnackBar(context, error.toString());
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendNotificationToDevice(String token, String title, String body) async {
    final String serverKey = 'AAAAgyaQYww:APA91bHP73jyX3necJR0LZFnE68IWrA2bzLLb2jAxAZoqc1gF41nzCSf_xVadnRFtPbUNrodzSLRqfcr7AMmjatne5uND2teh4bd4MM_zlXqUDfcLtzehFmWBBcPvCnX8YPq3_bA18Ar'; // Replace with your Firebase server key
    final String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final Map<String, dynamic> notification = {
      'body': body,
      'title': title,
    };

    final Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
    };

    final Map<String, dynamic> message = {
      'notification': notification,
      'data': data,
      'to': token,
    };

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: headers,
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<LatLng?> _getLocationUpdate() async {
    final Location locationController = Location();
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
      return await locationController.onLocationChanged
          .map((LocationData currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          return LatLng(currentLocation.latitude!, currentLocation.longitude!);
        }
        return null;
      }).first;
    }

    return null;
  }
}