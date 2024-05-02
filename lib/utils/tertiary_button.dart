import 'package:flutter/material.dart';

class TertiaryButton extends StatelessWidget {
  // final double height;
  // final double width;
  final String text;
  final VoidCallback onPressed;
  final Color foreground;
  final Color background;
  const TertiaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.foreground,
    required this.background,
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
              foregroundColor: MaterialStateProperty.all<Color>(foreground),
              backgroundColor: MaterialStateProperty.all<Color>(background),
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
