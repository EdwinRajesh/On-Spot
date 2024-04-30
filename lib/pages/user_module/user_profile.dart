// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

//import 'package:on_spot_mechanic/utils/secondary.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthorizationProvider>(context, listen: false);
    return Scaffold(
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
              automaticallyImplyLeading: false,
              title: Center(
                  child: Text(
                "My Profile",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor),
              )),
              elevation: 0, // Remove AppBar's default elevation
            ),
          )),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: primaryColor,
            backgroundImage: NetworkImage(ap.userModel.profilePic),
            radius: 64,
          ),
          const SizedBox(height: 20),
          Text(
            ap.userModel.name,
            style: TextStyle(
                fontSize: 28,
                color: secondaryColor,
                fontWeight: FontWeight.bold),
          ),
          Text(
            ap.userModel.phoneNumber ?? "",
            style: TextStyle(
                fontSize: 20, color: silver, fontWeight: FontWeight.bold),
          ),
          Text(
            ap.userModel.email,
            style: TextStyle(
              fontSize: 22,
              color: tertiaryColor,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          // SecondaryButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => ChatScreen()),
          //     );
          //   },
          //   text: 'Edit Profile',
          //   height: 40,
          //   width: 216,
          // )
        ],
      )),
    );
  }
}
