// ignore_for_file: prefer_const_constructors

import 'package:first/pages/user_module/user_home.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../models/car_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/button.dart';
import '../../utils/colors.dart';
import 'user_add_vehicle.dart';

class UserVehiclePage extends StatefulWidget {
  const UserVehiclePage({super.key});

  @override
  State<UserVehiclePage> createState() => _UserVehiclePageState();
}

class _UserVehiclePageState extends State<UserVehiclePage> {
  List<CarModel>? carList;
  IconData customIcon = IconData(0xea8e, fontFamily: 'MaterialIcons');

  @override
  void dispose() {
    // Cancel any ongoing asynchronous operations
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) {
        return '';
      }
      return text[0].toUpperCase() + text.substring(1);
    }

    final ap = Provider.of<AuthorizationProvider>(context, listen: false);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Shadow color
                spreadRadius: 2, // Spread radius
                blurRadius: 4, // Blur radius
                offset: Offset(0, 2), // Offset in the y direction
              ),
            ],
          ),
          child: AppBar(
            leading: GestureDetector(
                child: Icon(Icons.arrow_back),
                onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserHomeScreen()),
                    )),
            title: Center(
                child: Text(
              "My Vehicle",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor),
            )),
            elevation: 0, // Remove AppBar's default elevation
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the list of cars here
            Expanded(
              child: FutureBuilder<List<CarModel>>(
                future: ap.getCarDataFromFirestore(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    if (!mounted) {
                      // Check if the widget is still mounted
                      return SizedBox
                          .shrink(); // Return an empty widget if the widget is disposed
                    }
                    List<CarModel> cars = snapshot.data ?? [];
                    if (cars.isEmpty) {
                      return Center(
                          child: Text('No vehicles found.',
                              style: TextStyle(
                                fontSize: 24,
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                              )));
                    }
                    return ListView.builder(
                      itemCount: cars.length,
                      itemBuilder: (context, index) {
                        final car = cars[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1.0, // Adjust the width as needed
                                color: Colors
                                    .black, // Specify the color of the border
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            child: ListTile(
                              leading: car.carPictures.isNotEmpty
                                  ? Image.network(
                                      car.carPictures[
                                          0], // Display the first picture in the list
                                      width: 60,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.car_repair,
                                    ), // Display an icon if no pictures are available

                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        capitalizeFirstLetter(car.manufacture),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: secondaryColor,
                                            fontSize: 18),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        capitalizeFirstLetter(car.model),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: secondaryColor,
                                            fontSize: 18),
                                      )
                                    ],
                                  ),
                                  //Text('Reg. No : ${car.}'),
                                  Text(
                                    'Year: ${car.year}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Row(
                                    children: [
                                      Icon(customIcon),
                                      Text(
                                        car.fuel!,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete'),
                                    content: Text('Dialog Content'),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            CustomButton(
              onPressed: () {
                // Navigate to the add vehicle screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserAddVehicle()),
                );
              },
              text: 'Add Vehicle',
            ),
          ],
        ),
      ),
    );
  }
}
