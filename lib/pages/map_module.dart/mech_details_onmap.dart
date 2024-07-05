// ignore_for_file: prefer_const_constructors

import 'package:first/pages/user_module/send_mechanic_car.dart';
import 'package:first/utils/colors.dart';
import 'package:first/utils/secondary.dart';
import 'package:flutter/material.dart';

import '../../utils/button.dart';

class MechanicDetailsPage extends StatelessWidget {
  final Map<String, dynamic> mechanic;

  const MechanicDetailsPage({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mechanic['name'] ?? 'Mechanic Name',
          style: TextStyle(fontWeight: FontWeight.bold, color: secondaryColor),
        ),
        // Set appbar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                mechanic['profilePic'] ?? 'profilePic',
                width: 200.0,
                height: 200.0,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8.0),
            // Text(
            //   'Experience: ${mechanic['Experience']}',
            //   style: TextStyle(
            //       fontSize: 18.0,
            //       fontWeight: FontWeight.bold,
            //       color: secondaryColor),
            // ),
            // SizedBox(height: 8.0),
            SizedBox(height: 4.0),
            Text(
              '${mechanic['bio'] ?? 'No bio available.'}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 21.0),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    onPressed: () {
                      DialogBoxMethod(context);
                    },
                    // Set button shape

                    text: 'Quick Booking',
                  ),
                ),
                SizedBox(width: 21.0),
                // Expanded(
                //   child: SecondaryButton(
                //     onPressed: () {},
                //     text: 'Book Schedule',
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> DialogBoxMethod(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Quick Service Booking',
            style: TextStyle(color: secondaryColor, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conditions for Booking:',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  '1. Ensure vehicle is parked in a safe location.\n'
                  '2. Provide accurate information about the vehicle.\n'
                  '3. Agree to the terms and conditions of the service provider.\n'
                  '4. Confirm availability of the mechanic for the selected date and time.\n',
                  style: TextStyle(fontSize: 14.0),
                ),
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.center,
                  child: CustomButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SendMechanicVehicle(
                                  mechanic: mechanic,
                                )),
                      );
                    },
                    text: 'Continue Booking',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
