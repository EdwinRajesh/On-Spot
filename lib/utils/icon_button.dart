import 'package:flutter/material.dart';

class IconButtonWidget extends StatelessWidget {
  // final double height;
  // final double width;
  final Icon icon;
  final VoidCallback onPressed;
  final Color foreground;
  final Color background;
  const IconButtonWidget({
    super.key,
    required this.onPressed,
    required this.foreground,
    required this.background,
    required this.icon,
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
          child: icon),
    );
  }
}
