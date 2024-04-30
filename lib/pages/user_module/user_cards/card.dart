// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utils/colors.dart';

class UserCard extends StatelessWidget {
  final String svgPath;
  final String name;
  const UserCard({super.key, required this.name, required this.svgPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Shadow color
              spreadRadius: 5, // Spread radius
              blurRadius: 3, // Blur radius
              offset: Offset(0, 1), // Offset
            ),
          ],
        ),
        height: 140,
        width: 140,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
              child: SvgPicture.asset(
                svgPath, // Use the passed SVG icon path here
                width: 48, // Adjust width and height as needed
                height: 48,
                color: secondaryColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                style: TextStyle(
                    fontSize: 16, color: silver, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
