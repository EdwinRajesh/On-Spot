// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/user_tile.dart';
import 'user_messaging.dart';

class SelectedMechanicScreen extends StatefulWidget {
  final String mechanicName;
  final String mechanicProfilePicture;
  final String mechanicId;
  final String mechanicEmail;
  const SelectedMechanicScreen(
      {super.key,
      required this.mechanicName,
      required this.mechanicProfilePicture,
      required this.mechanicId,
      required this.mechanicEmail});

  @override
  State<SelectedMechanicScreen> createState() => _SelectedMechanicScreenState();
}

class _SelectedMechanicScreenState extends State<SelectedMechanicScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              backgroundImage: NetworkImage(widget.mechanicProfilePicture),
              radius: 22,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              widget.mechanicName,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: secondaryColor,
        foregroundColor: primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          UserTile(
            text: widget.mechanicName,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverEmail: widget.mechanicEmail,
                    receiverID: widget.mechanicId,
                    profilePic: widget.mechanicProfilePicture,
                    receiverName: widget.mechanicName,
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
