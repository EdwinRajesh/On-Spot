// ignore_for_file: prefer_const_constructors, library_prefixes, unnecessary_string_interpolations, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:first/pages/map_pages.dart';
import 'package:first/pages/user_module/user_cards/mech_card.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../models/user_models.dart';
import '../../providers/chat_services.dart';
import 'user_cards/chat_bot.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import 'user_cards/card.dart';
import 'user_cards/drawer_user.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  late UserModel _userModel;
  UserModel get userModel => _userModel;
  FirebaseAuth auth = FirebaseAuth.instance;
  final ChatService chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthorizationProvider>(context, listen: false);
    String name = ap.userModel.name.split(' ')[0];
    String userName = name[0].toUpperCase() + name.substring(1);
    return Scaffold(
      drawer: UserDrawer(),
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Hey, ",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      "$userName",
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: UserCard(
                        name: "2 Wheel Repair",
                        svgPath: 'assets/bike.svg',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPage(
                              selectedService: 'is2WheelRepairSelected',
                              serviceName: '2-Wheel Assistance',
                            ),
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      child: UserCard(
                        name: "4 Wheel Repair",
                        svgPath: 'assets/car.svg',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPage(
                              selectedService: 'is4WheelRepairSelected',
                              serviceName: '4-Wheel Assistance',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: UserCard(
                          name: "6 Wheel Repair", svgPath: 'assets/6wheel.svg'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPage(
                              selectedService: 'is6WheelRepairSelected',
                              serviceName: '6-Wheel Assistance',
                            ),
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      child: UserCard(
                        name: "Tow Service",
                        svgPath: 'assets/tow.svg',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPage(
                              selectedService: 'isTowSelected',
                              serviceName: 'Tow Service',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                _buildUserList(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen()),
          );
        },
        backgroundColor: primaryColor,
        child: Icon(
          Icons.android_outlined,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: MiddleRightFloatingActionButtonLocation(),
    );
  }
}

Widget _buildUserList() {
  final ChatService chatService = ChatService();

  return StreamBuilder(
      stream: chatService.getSelectedMechanicStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView(
            padding: EdgeInsets.zero,
            children: snapshot.data!
                .map<Widget>(
                    (userData) => _buildUserListItem(userData, context))
                .toList(),
          ),
        );
      });
}

Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
  final ChatService chatService = ChatService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  return FutureBuilder<List<String>>(
    future: chatService.getAcceptedMechanicUIDs(auth.currentUser!.phoneNumber!),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return SizedBox.shrink();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        List<String> mechanicUIDs = snapshot.data!;
        if (mechanicUIDs.contains(userData["phoneNumber"])) {
          return MechanicCardFromUserHomeScreen(
              mechanicId: userData["uid"],
              mechanicName: userData['name'],
              mechanicPicture: userData["profilePic"],
              mechanicEmail: userData["email"]);
        
        } else {
          return Container();
        }
      }
    },
  );
}

class MiddleRightFloatingActionButtonLocation
    extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double x = scaffoldGeometry.scaffoldSize.width - 88.0;
    final double screenHeight = scaffoldGeometry.scaffoldSize.height;
    final double buttonHeight = 56.0;
    final double y = screenHeight / 6 -
        buttonHeight / 1.4; // Position between middle and bottom
    return Offset(x, y);
  }
}
