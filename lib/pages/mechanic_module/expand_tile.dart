//import 'package:flutter/foundation.dart';
// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first/utils/icon_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../providers/chat_services.dart';
import '../../utils/tertiary_button.dart';
import '../../utils/utils.dart';
import 'mechanic_map.dart';
import '../../utils/colors.dart';

class MechanicNotification extends StatefulWidget {
  final String userName;
  final String userProfilePicture;
  final String text;
  final String fuel;
  final String year;
  final double latitude;
  final double longitude;
  final String profilePic;
  final String mechanicName;
  final String? mechanicId;
  final String model;
  final String picture;
  final String manufacture;
  final String problemDescription;

  const MechanicNotification({
    super.key,
    required this.userName,
    required this.userProfilePicture,
    required this.text,
    required this.fuel,
    required this.year,
    required this.model,
    required this.picture,
    required this.manufacture,
    required this.problemDescription,
    required this.latitude,
    required this.longitude,
    required this.profilePic,
    required this.mechanicName,
    required this.mechanicId,
  });

  @override
  State<MechanicNotification> createState() => _MechanicNotificationState();
}

class _MechanicNotificationState extends State<MechanicNotification> {
  bool _rejected = false;
  bool _acceptButtonClicked = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  void _handleButtonClick(bool isAccepted) async {
    setState(() {
      if (isAccepted) {
        _acceptButtonClicked = true;
      } else {
        _rejected = true;
      }
    });

    // Perform any additional actions based on the button click (accepted or rejected)
    if (isAccepted) {
      try {
        ChatService chatService = ChatService();
        await chatService.SendMechanicResponse(
          userName: widget.userName,
          problemDescription: widget.problemDescription,
          model: widget.model,
          manufacture: widget.manufacture,
          fuel: widget.fuel,
          year: widget.year,
          mechanicId: widget.mechanicId!,
          longitude: widget.longitude,
          latitude: widget.latitude,
          profilePic: widget.profilePic,
          name: widget.mechanicName,
          userId: widget.text,
        );
        try {
          await FirebaseFirestore.instance
              .collection('mechanic')
              .doc(widget.mechanicId)
              .collection('service_requests')
              .doc(widget.text)
              .delete();
        } catch (e) {
          showSnackBar(context, "Error");
        }
        showSnackBar(context, "user request accepted");
      } catch (error) {
        showSnackBar(context, "message not sent try again");
      }
    }
    if (_rejected) {
      try {
        await FirebaseFirestore.instance
            .collection('mechanic')
            .doc(widget.mechanicId)
            .collection('service_requests')
            .doc(widget.text)
            .delete();
        showSnackBar(context, "Request rejected ");
      } catch (e) {
        showSnackBar(context, "Error in deleting the request");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rejected) {
      return Container();
    }

    IconData customIcon = IconData(0xea8e, fontFamily: 'MaterialIcons');

    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) {
        return '';
      }
      return text[0].toUpperCase() + text.substring(1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        decoration: BoxDecoration(
            color: secondaryColor, borderRadius: BorderRadius.circular(8)),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
          leading: CircleAvatar(
            radius: 20, // Adjust the size of the circle avatar as needed
            backgroundImage: NetworkImage(
                widget.userProfilePicture), // Provide the image URL
          ),
          title: Row(
            children: [
              SizedBox(width: 10),
              Text(
                widget.userName,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.network(
                        widget.picture, // Display the first picture in the list
                        width: 70,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                capitalizeFirstLetter(widget.manufacture),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                capitalizeFirstLetter(widget.model),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18),
                              )
                            ],
                          ),
                          //Text('Reg. No : ${car.}'),
                          Text(
                            widget.year,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                customIcon,
                                color: Colors.white,
                              ),
                              Text(
                                widget.fuel,
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    widget.problemDescription,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButtonWidget(
                        icon: Icon(Icons.location_pin),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MechanicMap(
                                latitude: widget.latitude,
                                longitude: widget.longitude,
                              ),
                            ),
                          );
                        },
                        foreground: secondaryColor,
                        background: primaryColor,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      if (!_acceptButtonClicked)
                        Row(
                          children: [
                            TertiaryButton(
                              text: "Reject",
                              onPressed: () => _handleButtonClick(false),
                              foreground: secondaryColor,
                              background: Colors.red,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            TertiaryButton(
                              text: "Accept",
                              onPressed: () async {
                                _handleButtonClick(true);
                                try {
                                  LatLng? position = await _getLocationUpdate();
                                  ChatService chatService = ChatService();
                                  await chatService.SendMechanicResponse(
                                      mechanicId: auth.currentUser!.uid,
                                      longitude: position?.longitude ?? 0.0,
                                      latitude: position?.latitude ?? 0.0,
                                      profilePic: widget.userProfilePicture,
                                      name: widget.mechanicName,
                                      userId: widget.text,
                                      problemDescription:
                                          widget.problemDescription,
                                      model: widget.model,
                                      fuel: widget.fuel,
                                      userName: widget.userName,
                                      manufacture: widget.manufacture,
                                      year: widget.year);
                                  showSnackBar(context,
                                      "Send notificaton to ${widget.userName}");
                                } catch (error) {
                                  showSnackBar(context, error.toString());
                                }
                              },
                              foreground: secondaryColor,
                              background: primaryColor,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

    return null; // Return null if location permission is not granted
  }
}
