// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_literals_to_create_immutables, unused_element
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first/pages/mechanic_module/mechanic_profile.dart';
import 'package:first/utils/expansion_tiles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_services.dart';

import '../../utils/colors.dart';
import '../../utils/user_tile.dart';
import '../user_module/user_messaging.dart';

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
              _buildUserList(chatService, auth),
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
        return Text(
            "No user requests available"); // Show a message when there is no data
      }

      // Build the list of user request items
      return Container(
        height: 250,
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
          return ExpandedTiles(
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

Widget _buildUserList(ChatService chatService, FirebaseAuth auth) {
  return StreamBuilder(
    stream: chatService.getUserStream(),
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
  FirebaseAuth auth = FirebaseAuth.instance;

  if (userData["email"] != auth.currentUser?.email) {
    return UserTile(
      text: userData["name"],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              profilePic: userData['profilePic'],
              receiverEmail: userData["email"],
              receiverID: userData["uid"],
            ),
          ),
        );
      },
    );
  } else {
    return Container();
  }
}
