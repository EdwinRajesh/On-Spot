// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import '../authentication_module/welcome.dart';

class MechanicProfilePage extends StatefulWidget {
  const MechanicProfilePage({super.key});

  @override
  State<MechanicProfilePage> createState() => _MechanicProfilePageState();
}

class _MechanicProfilePageState extends State<MechanicProfilePage> {
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
              actions: [
                GestureDetector(
                  child: IconButton(
                    icon: Icon(
                      Icons.exit_to_app,
                      color: secondaryColor,
                      size: 24,
                    ),
                    onPressed: () {
                      ap.userSignOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => WelcomePage()),
                      );
                    },
                  ),
                ),
              ],
              leading: GestureDetector(
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: secondaryColor,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // ap.userSignOut();
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => WelcomePage()),
                    //);
                  },
                ),
              ),
              automaticallyImplyLeading: true,
              title: Text(
                "My Profile",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor),
              ),
              elevation: 0, // Remove AppBar's default elevation
            ),
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
              child: Column(
            children: [
              SizedBox(
                height: 128,
              ),
              CircleAvatar(
                  backgroundColor: primaryColor,
                  backgroundImage: NetworkImage(ap.mechanicModel.profilePic),
                  radius: 64),
              const SizedBox(height: 20),
              Text(
                ap.mechanicModel.name,
                style: TextStyle(
                    fontSize: 28,
                    color: secondaryColor,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                ap.mechanicModel.email,
                style: TextStyle(
                  fontSize: 22,
                  color: tertiaryColor,
                ),
              ),
              Text(
                ap.mechanicModel.phoneNumber ?? "",
                style: TextStyle(
                    fontSize: 20, color: silver, fontWeight: FontWeight.bold),
              ),
              Text(
                ap.mechanicModel.qualification,
                style: TextStyle(
                    fontSize: 20, color: silver, fontWeight: FontWeight.bold),
              )
            ],
          )),
        ),
      ),
    );
  }
}
