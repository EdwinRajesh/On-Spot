// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, must_be_immutable
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/mechanic_model.dart';
import '../../../providers/chat_services.dart';
import '../../../utils/colors.dart';
import '../../../utils/user_tile.dart';
import '../user_messaging.dart';

class NearbyMechanicsScreen extends StatefulWidget {
  final String selectedService;
  final String serviceName;

  NearbyMechanicsScreen(
      {super.key, required this.selectedService, required this.serviceName});
  final ChatService chatService = ChatService();
  //AuthorizationProvider auth = AuthorizationProvider();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  _NearbyMechanicsScreenState createState() => _NearbyMechanicsScreenState();
}

class _NearbyMechanicsScreenState extends State<NearbyMechanicsScreen> {
  List<MechanicModel> mechanicsList = [];

  @override
  void initState() {
    super.initState();
    // fetchMechanics(widget.selectedService);
  }

  @override
  Widget build(BuildContext context) {
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
              automaticallyImplyLeading: true,
              title: Text(
                "Available mechanics",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor),
              ),
              elevation: 0, // Remove AppBar's default elevation
            ),
          )),
      body: Column(children: [_buildUserList()]),
      //LaterUse(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: widget.chatService.getMechanicsStream(widget.selectedService),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          return Container(
            height: 300,
            child: ListView(
              children: snapshot.data!
                  .map<Widget>(
                      (userData) => _buildUserListItem(userData, context))
                  .toList(),
            ),
          );
        });
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != widget.auth.currentUser?.email) {
      return UserTile(
        text: userData["name"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                  receiverEmail: userData["email"],
                  receiverID: userData["uid"],
                  profilePic: userData["profilePic"],
                  receiverName: userData['name']),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
