import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first/pages/mechanic_module/selected_user.dart';
import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

class UserCardFromMechanicHomeScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String mechanicId;
  // final String vehicleYear;
  // final String vehicleFuel;
  // final String problemDescription;
  // final String vehiclePicture;
  final double? longitude;
  final double? latitude;

  // final String vehicleManufacture;
  const UserCardFromMechanicHomeScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.mechanicId,
    required this.longitude,
    required this.latitude,

    // required this.vehicleYear,
    // required this.vehicleFuel,
    // required this.problemDescription,
    // required this.vehiclePicture,
    // required this.vehicleManufacture
  });

  @override
  Widget build(BuildContext context) {
    Future<String> fetchEmailByUserId(String userId) async {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      Map<String, dynamic> userData =
          docSnapshot.data() as Map<String, dynamic>;
      return userData['email'] as String;
    }

    Future<String> fetchPhotoByUserId(String userId) async {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      Map<String, dynamic> userData =
          docSnapshot.data() as Map<String, dynamic>;
      return userData['profilePic'] as String;
    }

    return GestureDetector(
      onTap: () async {
        String email = await fetchEmailByUserId(userId);
        String userPhoto = await fetchPhotoByUserId(userId);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SelectedUserFromMechanicInterface(
                  latitude: latitude,
                  longitude: longitude,
                  userEmail: email,
                  userPhoto: userPhoto,
                  userId: userId,
                  userName: userName,
                  mechanicId: mechanicId)
              // ChatPage(
              //   receiverEmail: email,
              //   receiverID: userId,
              //   profilePic: userPhoto,
              //   receiverName: userName,
              // ),
              ),
        );
      },
      child: Container(
          decoration: BoxDecoration(
              color: secondaryColor, borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Text(
                userName,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          )),
    );
  }
}
