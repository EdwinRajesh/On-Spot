//import 'package:flutter/foundation.dart';
// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'colors.dart';

class ExpandedTiles extends StatelessWidget {
  final String text;
  final String fuel;
  final String year;
  final String model;
  final String picture;
  final String manufacture;
  final String problemDescription;

  const ExpandedTiles({
    super.key,
    required this.text,
    required this.fuel,
    required this.year,
    required this.model,
    required this.picture,
    required this.manufacture,
    required this.problemDescription,
  });

  @override
  Widget build(BuildContext context) {
    IconData customIcon = IconData(0xea8e, fontFamily: 'MaterialIcons');

    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) {
        return '';
      }
      return text[0].toUpperCase() + text.substring(1);
    }

    return Container(
      decoration: BoxDecoration(
          color: secondaryColor, borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        leading: Icon(Icons.person),
        title: Text(
          text,
          style: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.network(
                      picture, // Display the first picture in the list
                      width: 70,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              capitalizeFirstLetter(manufacture),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              capitalizeFirstLetter(model),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18),
                            )
                          ],
                        ),
                        //Text('Reg. No : ${car.}'),
                        Text(
                          year,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              customIcon,
                              color: Colors.white,
                            ),
                            Text(
                              fuel,
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  problemDescription,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
