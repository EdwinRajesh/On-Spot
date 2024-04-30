// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

class CarTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  const CarTextField(
      {super.key,
      required this.hintText,
      required this.controller,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: secondaryColor,
      controller: controller,
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: TextStyle(
            color: silver,
            fontWeight: FontWeight.bold), // Customize label color
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: secondaryColor), // Customize focused border color
        ),
        prefixIcon: Icon(icon), // Add icon to the leading side
        border: OutlineInputBorder(),
      ),
    );
  }
}
