// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:first/pages/user_module/user_request_mechanic.dart';
import 'package:first/utils/colors.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../models/car_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/button.dart';
import '../map_module.dart/mech_details_onmap.dart';

class SendMechanicVehicle extends StatefulWidget {
  final Map<String, dynamic> mechanic;

  const SendMechanicVehicle({super.key, required this.mechanic});

  @override
  State<SendMechanicVehicle> createState() => _SendMechanicVehicleState();
}

class _SendMechanicVehicleState extends State<SendMechanicVehicle> {
  IconData customIcon = IconData(0xea8e, fontFamily: 'MaterialIcons');
  FirebaseAuth auth = FirebaseAuth.instance;
  late List<bool> isSelected = [];
  late int selectedIndex = -1;
  late List<CarModel> cars = [];

  @override
  void initState() {
    super.initState();
    fetchCars(); // Fetch cars when the widget is initialized
  }

  Future<void> fetchCars() async {
    try {
      final ap = Provider.of<AuthorizationProvider>(context, listen: false);
      List<CarModel> fetchedCars = await ap.getCarDataFromFirestore();
      setState(() {
        cars = fetchedCars;
        isSelected = List.generate(cars.length, (index) => false);
      });
    } catch (error) {
      // Handle error
      print('Error fetching cars: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                title: Text("My Vehicles",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor)),
                leading: GestureDetector(
                  child: Icon(Icons.arrow_back),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MechanicDetailsPage(mechanic: widget.mechanic),
                      ),
                    );
                  },
                ),
                toolbarHeight: 32,
              ))),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  final car = cars[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: car.carPictures.isNotEmpty
                            ? Image.network(
                                car.carPictures[0],
                                width: 70,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.car_repair),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.manufacture,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              car.model,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text('Year: ${car.year}',
                                style: TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                Icon(customIcon),
                                Text(car.fuel!),
                              ],
                            ),
                          ],
                        ),
                        trailing: selectedIndex == index
                            ? Icon(Icons.check_circle,
                                color: primaryColor) // Selected vehicle
                            : SizedBox(),
                      ),
                    ),
                  );
                },
              ),
            ),
            CustomButton(
              onPressed: () {
                // Check if a vehicle is selected
                if (selectedIndex != -1) {
                  // Get the selected car
                  CarModel selectedCar = cars[selectedIndex];

                  // Navigate to the UserRequestMechanic page and pass the selected car's information
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserRequestMechanic(
                        car: selectedCar,
                        mechanic:
                            widget.mechanic, // Pass the mechanic property here
                      ),
                    ),
                  );
                } else {
                  // Show a message if no vehicle is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a vehicle')),
                  );
                }
              },
              text: 'Send Vehicle',
            ),
          ],
        ),
      ),
    );
  }
}
