// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, must_be_immutable
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/mechanic_model.dart';
import '../../providers/chat_services.dart';
import '../../utils/colors.dart';
import '../../utils/user_tile.dart';
import 'user_messaging.dart';

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
                widget.serviceName,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor),
              ),
              elevation: 0, // Remove AppBar's default elevation
            ),
          )),
      body: _buildUserList(),
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

          return ListView(
            children: snapshot.data!
                .map<Widget>(
                    (userData) => _buildUserListItem(userData, context))
                .toList(),
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
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  // ListView LaterUse() {
  //   return ListView.builder(
  //     itemCount: mechanicsList.length,
  //     itemBuilder: (context, index) {
  //       return ListTile(
  //         title: Center(
  //           child: GestureDetector(
  //             child: Row(
  //               children: [
  //                 Text(
  //                   mechanicsList[index].name,
  //                   style: TextStyle(fontSize: 18),
  //                 ),
  //                 Icon(
  //                   Icons.message,
  //                   size: 24,
  //                 )
  //               ],
  //             ),
  //             onTap: () {},
  //           ),
  //         ),
  //         // Add any additional information you want to display for each mechanic
  //       );
  //     },
  //   );
  // }
}


  // Future<void> fetchMechanics(String selectedService) async {
  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('mechanic')
  //         .where(selectedService, isEqualTo: true)
  //         .get();

  //     mechanicsList.clear();

  //     querySnapshot.docs.forEach((doc) {
  //       // Convert each document to a MechanicModel object and add it to the list
  //       MechanicModel mechanic = MechanicModel(
  //         name: doc['name'],
  //         email: doc['email'],
  //         is2WheelRepairSelected: doc['is2WheelRepairSelected'],
  //         uid: doc['uid'],
  //         phoneNumber: doc['phoneNumber'],
  //         createdAt: doc['createdAt'],
  //         profilePic: doc['createdAt'],
  //         is6WheelRepairSelected: doc['is6WheelRepairSelected'],
  //         is4WheelRepairSelected: doc['is4WheelRepairSelected'],
  //         qualification: doc['qualification'],
  //         isTowSelected: doc['isTowSelected'],
  //         // Populate other fields as needed
  //       );
  //       mechanicsList.add(mechanic);
  //     });

  //     // Update the UI after fetching mechanics
  //     setState(() {});
  //   } catch (error) {
  //     print('Error fetching mechanics: $error');
  //     // Handle the error gracefully, e.g., show an error message to the user
  //   }
  // }
