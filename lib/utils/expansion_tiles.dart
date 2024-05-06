//import 'package:flutter/foundation.dart';
// ignore_for_file: prefer_const_constructors

import 'package:first/utils/icon_button.dart';
import 'package:flutter/material.dart';
import '../pages/mechanic_module/mechanic_map.dart';
import 'colors.dart';

class ExpandedTiles extends StatelessWidget {
  final String userName;
  final String userProfilePicture;
  final String text;
  final String fuel;
  final String year;
  final double latitude;
  final double longitude;
  final String model;
  final String picture;
  final String manufacture;
  final String problemDescription;

  const ExpandedTiles({
    super.key,
    required this.userName,
    required this.userProfilePicture,
    required this.text,
    required this.fuel,
    required this.year,
    required this.model,
    required this.picture,
    required this.manufacture,
    required this.problemDescription,
    required this.latitude,
    required this.longitude,
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        decoration: BoxDecoration(
            color: secondaryColor, borderRadius: BorderRadius.circular(8)),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
          leading: CircleAvatar(
            radius: 20, // Adjust the size of the circle avatar as needed
            backgroundImage:
                NetworkImage(userProfilePicture), // Provide the image URL
          ),
          title: Row(
            children: [
              SizedBox(width: 10),
              Text(
                userName,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                  ),
                  IconButtonWidget(
                    icon: Icon(Icons.location_pin),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MechanicMap(
                                  latitude: latitude,
                                  longitude: longitude,
                                )),
                      );
                    },
                    foreground: secondaryColor,
                    background: primaryColor,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
