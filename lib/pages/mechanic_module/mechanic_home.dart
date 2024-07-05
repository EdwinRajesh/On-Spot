// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_literals_to_create_immutables, unused_element, prefer_const_constructors_in_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first/pages/mechanic_module/expand_tile.dart';
import 'package:first/pages/mechanic_module/mechanic_profile.dart';
import 'package:first/pages/mechanic_module/mechanic_stateless/user_card_from_mechanic_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_services.dart';

import '../../utils/colors.dart';

class MechanicHomeScreen extends StatefulWidget {
  MechanicHomeScreen({super.key});

  @override
  State<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  final ChatService chatService = ChatService();
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthorizationProvider>(context, listen: false);
    String name = ap.mechanicModel.name.split(' ')[0];
    String userName = name[0].toUpperCase() + name.substring(1);
    return Scaffold(
      appBar: AppBar(
          title: Text("Mechanic"),
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: secondaryColor,
              size: 32,
            ),
            onPressed: () {},
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  child: CircleAvatar(
                      backgroundColor: primaryColor,
                      backgroundImage:
                          NetworkImage(ap.mechanicModel.profilePic),
                      radius: 20),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MechanicProfilePage()),
                  ),
                ))
          ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Hey, ",
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    // ignore: unnecessary_string_interpolations
                    "$userName",
                    style: TextStyle(
                        color: primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              _buildUserRequestList(chatService, auth),
              SizedBox(
                height: 48,
              ),
              _buildUserList(chatService, auth, context),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildUserRequestList(ChatService chatService, FirebaseAuth auth) {
  return StreamBuilder(
    stream:
        chatService.getUserRequestStream(auth.currentUser?.phoneNumber ?? ''),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text("Error: ${snapshot.error}");
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator(); // Show a loading indicator
      }

      if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 8.0, 0),
            child: Text(
              "No new user requests available",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(31, 0, 0, 0)),
            ),
          ),
        ); // Show a message when there is no data
      }

      return SizedBox(
        height: 350,
        child: ListView(
          children: (snapshot.data as List).map<Widget>((userData) {
            return _buildUserRequestListItem(userData, context);
          }).toList(),
        ),
      );
    },
  );
}

Widget _buildUserRequestListItem(
    Map<String, dynamic> userData, BuildContext context) {
  return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(userData['carId'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data != null) {
          // Explicitly cast the snapshot data to Map<String, dynamic>
          Map<String, dynamic> userCarData =
              (snapshot.data!.data() as Map<String, dynamic>);
          String userName = userCarData['name'];
          double latitude = (userData['latitude'] as double?) ?? 0.0;
          double longitude = (userData['longitude'] as double?) ?? 0.0;
          final ap = Provider.of<AuthorizationProvider>(context, listen: false);
          return MechanicNotification(
              profilePic: ap.mechanicModel.profilePic,
              mechanicName: ap.mechanicModel.name,
              mechanicId: ap.mechanicModel.phoneNumber,
              longitude: longitude, // Convert to double or use default value
              latitude: latitude,
              userProfilePicture: userCarData['profilePic'] ?? "",
              userName: userName,
              text: userData['carId'],
              fuel: userData['fuel'] ?? "",
              year: userData['year'] ?? "",
              picture: userData['picture'] ?? "",
              model: userData['model'] ?? "",
              manufacture: userData['manufacture'] ?? "",
              problemDescription: userData['problemDescription'] ?? "");
        } else {
          return Center(
            child: Text(
              'No requests present',
              style: TextStyle(color: secondaryColor, fontSize: 32),
            ),
          );
        }
      });
}

Widget _buildUserList(
    ChatService chatService, FirebaseAuth auth, BuildContext context) {
  return StreamBuilder(
    stream:
        chatService.getAcceptedUserStream(auth.currentUser?.phoneNumber ?? ''),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Text("Error");
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text("Loading");
      }

      return SizedBox(
        height: 200,
        child: ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        ),
      );
    },
  );
}

Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
  return UserCardFromMechanicHomeScreen(
    userId: userData['userId'],
    userName: userData['userName'],
    latitude: userData['latitude'],
    longitude: userData['longitude'],

    mechanicId: userData['mechanicId'],
    // vehicleManufacture: userData['manufacture']
  );
}

Future<String> fetchEmailByUserId(String userId) async {
  DocumentSnapshot docSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  Map<String, dynamic> userData = docSnapshot.data() as Map<String, dynamic>;
  return userData['email'] as String;
}
