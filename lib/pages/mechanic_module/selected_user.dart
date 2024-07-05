// ignore_for_file: prefer_const_constructors

import 'package:first/pages/mechanic_module/mechanic_map.dart';
import 'package:first/utils/user_tile.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../user_module/user_messaging.dart';

class SelectedUserFromMechanicInterface extends StatefulWidget {
  final double? latitude;
  final String userName;
  final String mechanicId;
  final double? longitude;
  final String userEmail;
  final String userPhoto;
  final String userId;
  const SelectedUserFromMechanicInterface(
      {super.key,
      required this.latitude,
      required this.longitude,
      required this.userEmail,
      required this.userPhoto,
      required this.userId,
      required this.userName,
      required this.mechanicId});

  @override
  State<SelectedUserFromMechanicInterface> createState() =>
      _SelectedUserFromMechanicInterfaceState();
}

class _SelectedUserFromMechanicInterfaceState
    extends State<SelectedUserFromMechanicInterface> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              backgroundImage: NetworkImage(widget.userPhoto),
              radius: 22,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(widget.userName),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: secondaryColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MechanicMap(
                              latitude: widget.longitude ?? 0.0,
                              longitude: widget.latitude ?? 0.0,
                            ))),
                child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 56, vertical: 16),
                    decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(8)),
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "User Location",
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            Icons.location_pin,
                            color: primaryColor,
                            size: 24,
                          )
                        ],
                      ),
                    )),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            UserTile(
              text: "Message",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverEmail: widget.userEmail,
                      receiverID: widget.userId,
                      profilePic: widget.userPhoto,
                      receiverName: widget.userName,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
