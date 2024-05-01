// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';

import 'colors.dart';

class SecondaryButton extends StatelessWidget {
  // final double height;
  // final double width;
  final String text;
  final VoidCallback onPressed;
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    // required this.height,
    // required this.width"
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: width,
      // height: height,
      child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
              backgroundColor: MaterialStateProperty.all<Color>(secondaryColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)))),
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          )),
    );
  }
}
