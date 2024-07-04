import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../selected_mechanic_interface.dart';

class MechanicCardFromUserHomeScreen extends StatelessWidget {
  final String mechanicId;
  final String mechanicName;

  final String mechanicPicture;
  final String mechanicEmail;

  const MechanicCardFromUserHomeScreen({
    super.key,
    required this.mechanicId,
    required this.mechanicName,
    required this.mechanicPicture,
    required this.mechanicEmail,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedMechanicScreen(
              mechanicId: mechanicId,
              mechanicName: mechanicName,
              mechanicProfilePicture: mechanicPicture,
              mechanicEmail: mechanicEmail,
            ),
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
              CircleAvatar(
                  radius: 20, backgroundImage: NetworkImage(mechanicPicture)),
              const SizedBox(width: 12),
              Text(
                mechanicName,
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
