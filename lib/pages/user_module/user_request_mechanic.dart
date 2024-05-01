// ignore_for_file: unnecessary_import, prefer_const_constructors

import 'package:first/pages/user_module/user_cards/user_nav_screen.dart';
import 'package:first/providers/chat_services.dart';
import 'package:first/utils/secondary.dart';
import 'package:first/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../models/car_model.dart';

class UserRequestMechanic extends StatefulWidget {
  final CarModel car;
  final Map<String, dynamic> mechanic;
  // Add a field to store the selected car

  const UserRequestMechanic(
      {required this.car, super.key, required this.mechanic});

  @override
  State<UserRequestMechanic> createState() => _UserRequestMechanicState();
}

class _UserRequestMechanicState extends State<UserRequestMechanic> {
  String problemDescription =
      ''; // Add a variable to store the problem description

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Mechanic'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Describe the problem with the vehicle:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextFormField(
                  maxLines: 4, // Adjust the number of lines as needed
                  onChanged: (value) {
                    setState(() {
                      problemDescription =
                          value; // Update the problem description
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter problem description...',
                    border: OutlineInputBorder(),
                  ),
                ),
                ListTile(
                  leading: widget.car.carPictures.isNotEmpty
                      ? Image.network(
                          widget.car.carPictures[0],
                          width: 100,
                          height: 320,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.car_repair),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.car.manufacture,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.car.model,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text('Year: ${widget.car.year}',
                          style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          Icon(Icons.local_gas_station),
                          Text(widget.car.fuel!),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 14,
                ),
                SecondaryButton(
                  text: 'Send Message',
                  onPressed: () async {
                    try {
                      ChatService chatService = ChatService();
                      await chatService.sendServiceRequest(
                          widget.mechanic['uid'],
                          widget.car.model,
                          widget.car.uid!,
                          problemDescription);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserNavPage(index: 1),
                        ),
                      );
                    } catch (error) {
                      showSnackBar(context, error.toString());
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
