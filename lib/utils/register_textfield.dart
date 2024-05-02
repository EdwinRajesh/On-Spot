import 'package:first/utils/colors.dart';
import 'package:flutter/material.dart';

class RegisterTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController widgetController;
  const RegisterTextField(
      {super.key,
      required this.hintText,
      required this.widgetController,
      required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextFormField(
        obscureText: obscureText,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        controller: widgetController,
        cursorColor: primaryColor,
        decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
      ),
    );
  }
}
