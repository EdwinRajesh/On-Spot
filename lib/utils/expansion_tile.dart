// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'colors.dart';

class CustomExpansionTile extends StatelessWidget {
  final String picture;
  final String text;
  final String profilePic;
  final String userId;
  final String problemDescription;
  final String model;
  final String fuel;
  final String year;
  final String manufacture;
  final void Function()? onTap;

  const CustomExpansionTile({
    super.key,
    required this.text,
    required this.profilePic,
    required this.problemDescription,
    this.onTap,
    required this.userId,
    required this.model,
    required this.picture,
    required this.fuel,
    required this.year,
    required this.manufacture,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: secondaryColor, borderRadius: BorderRadius.circular(8)),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: primaryColor,
            backgroundImage: NetworkImage(profilePic),
            radius: 22,
          ),
          title: Text(
            text,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          children: [
            ListTile(
              title: Text(
                problemDescription,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              subtitle: Text(model),
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
