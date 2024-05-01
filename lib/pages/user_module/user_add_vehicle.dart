// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'dart:io';

import 'package:first/pages/user_module/user_cards/user_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import 'package:provider/provider.dart';

import '../../models/car_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/button.dart';
import '../../utils/colors.dart';
import '../../utils/utils.dart';
import 'user_cards/car_textfield.dart';

class UserAddVehicle extends StatefulWidget {
  const UserAddVehicle({super.key});

  @override
  State<UserAddVehicle> createState() => _UserAddVehicleState();
}

class _UserAddVehicleState extends State<UserAddVehicle> {
  List<File> _selectedImages = [];

  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _manufactureController = TextEditingController();

  String? _selectedFuelType;
  int? _selectedManufactureYear;

  void selectImage() async {
    File? pickedImage = await pickImage(context);
    if (pickedImage != null) {
      _selectedImages.add(pickedImage);
      setState(() {});
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
                leading: GestureDetector(
                    child: Icon(Icons.arrow_back),
                    onTap: () => Navigator.of(context).pop()),
                title: Text(
                  "Add Vehicle",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor),
                ),
              ))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: _selectedImages.isNotEmpty
                ? Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _selectedImages.map((image) {
                      return SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                        ),
                      );
                    }).toList(),
                  )
                : GestureDetector(
                    onTap: selectImage,
                    child: Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
          ),
          const SizedBox(
            height: 16,
          ),
          CarTextField(
              hintText: "Manufacture",
              controller: _manufactureController,
              icon: Icons.branding_watermark_outlined),
          SizedBox(
            height: 8,
          ),
          CarTextField(
              hintText: "Vehicle Name",
              controller: _vehicleNameController,
              icon: LineIcons.car),
          SizedBox(
            height: 8,
          ),
          CarTextField(
              hintText: "Registration Number",
              controller: _registrationNumberController,
              icon: Icons.numbers),
          const SizedBox(height: 16.0),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Fuel Type',
              labelStyle: TextStyle(
                  color: Color(0xFFBBB8B2), fontWeight: FontWeight.bold),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00A8A8)),
              ),
            ),
            value: _selectedFuelType,
            onChanged: (value) {
              setState(() {
                _selectedFuelType = value;
              });
            },
            items: ['Petrol', 'Diesel', 'Electric', 'CNG']
                .map((fuelType) => DropdownMenuItem<String>(
                      value: fuelType,
                      child: Text(fuelType),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16.0),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Manufacture Year',
              labelStyle: TextStyle(
                  color: Color(0xFFBBB8B2), fontWeight: FontWeight.bold),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00A8A8)),
              ),
            ),
            value: _selectedManufactureYear,
            onChanged: (value) {
              setState(() {
                _selectedManufactureYear = value;
              });
            },
            items: List.generate(
              DateTime.now().year - 1970 + 1,
              (index) => DropdownMenuItem<int>(
                value: 1970 + index,
                child: Text('${1970 + index}'),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          CustomButton(
              text: "Update",
              onPressed: () {
                storeData();
              })
        ]),
      ),
    );
  }

  void storeData() async {
    if (_manufactureController.text.isEmpty ||
        _vehicleNameController.text.isEmpty ||
        _registrationNumberController.text.isEmpty ||
        _selectedFuelType == null ||
        _selectedManufactureYear == null ||
        _selectedImages.isEmpty) {
      // Display a Snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all the fields.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final ap = Provider.of<AuthorizationProvider>(context, listen: false);

    CarModel carModel = CarModel(
      uid: '',
      manufacture: _manufactureController.text.trim(),
      model: _vehicleNameController.text.trim(),
      year: _selectedManufactureYear.toString(),
      fuel: _selectedFuelType,
      carPictures: [], // Initialize carPictures as an empty list
    );

    ap.saveCarDataToFirebase(
      context: context,
      OnSuccess: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserNavPage(
                    index: 0,
                  )),
        );
      },
      carModel: carModel,
      carPictures: _selectedImages, // Pass the list of selected images
    );
  }
}
