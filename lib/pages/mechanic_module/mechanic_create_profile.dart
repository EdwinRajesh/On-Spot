// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart';

import 'package:first/pages/mechanic_module/mechanic_home.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/mechanic_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/button.dart';
import '../../utils/colors.dart';
import '../../utils/signup_textfield.dart';
import '../../utils/utils.dart';

class MechanicProfile extends StatefulWidget {
  const MechanicProfile({super.key});

  @override
  State<MechanicProfile> createState() => _MechanicProfileState();
}

class _MechanicProfileState extends State<MechanicProfile> {
  File? image;
  bool is4WheelRepairSelected = false;
  bool is6WheelRepairSelected = false;
  bool is2WheelRepairSelected = false;
  bool isTowSelected = false;
  List<String> selectedServices = [];
  bool checkBoxvalue = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
  }

  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.arrow_back),
            onTap: () {
              AuthorizationProvider auth = AuthorizationProvider();
              auth.userSignOut();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
              child: Column(
                children: [
                  Text(
                    'Get On Board!',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your profile to start your Journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  InkWell(
                    onTap: () => selectImage(),
                    child: image == null
                        ? const CircleAvatar(
                            backgroundColor: Color(0xFF00A8A8),
                            radius: 50,
                            child: Icon(
                              Icons.account_circle,
                              size: 100,
                              color: Colors.white,
                            ),
                          )
                        : CircleAvatar(
                            backgroundImage: FileImage(image!),
                            radius: 50,
                          ),
                  ),
                  SizedBox(height: 24),
                  SignTextField(
                      hintText: "Full Name",
                      controller: nameController,
                      icon: Icons.person_outline_rounded),
                  SizedBox(
                    height: 8,
                  ),
                  SignTextField(
                      hintText: "E-Mail",
                      controller: emailController,
                      icon: Icons.email_outlined),
                  SizedBox(
                    height: 8,
                  ),
                  TextField(
                    controller: bioController,
                    cursorColor: primaryColor,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Bio",
                      prefixIcon: Icon(Icons.book),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  serviceCheckBox(),
                  SizedBox(
                    height: 4,
                  ),
                  secondServiceCheckBox(),
                  SizedBox(
                    height: 16,
                  ),
                  CustomButton(
                      text: "SIGN UP",
                      onPressed: () {
                        _getLocationUpdate();
                      })
                ],
              ),
            ),
          ),
        ));
  }

  Row secondServiceCheckBox() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color.fromARGB(255, 236, 244, 243)),
            child: CheckboxListTile(
              activeColor: primaryColor,
              value: is6WheelRepairSelected,
              onChanged: (value) {
                setState(() {
                  is6WheelRepairSelected = value!;
                });
              },
              title: Text("6-wheel Repair",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ),
        SizedBox(
          width: 4,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color.fromARGB(255, 236, 244, 243)),
            child: CheckboxListTile(
              activeColor: primaryColor,
              value: isTowSelected,
              onChanged: (value) {
                setState(() {
                  isTowSelected = value!;
                });
              },
              title: Text("Tow Service",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }

  Row serviceCheckBox() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color.fromARGB(255, 236, 244, 243)),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              activeColor: primaryColor,
              value: is4WheelRepairSelected,
              onChanged: (value) {
                setState(() {
                  is4WheelRepairSelected = value!;
                });
              },
              title: Text("4-Wheel Repair",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ),
        SizedBox(
          width: 4,
        ),
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromARGB(255, 236, 244, 243)),
          child: CheckboxListTile(
            activeColor: primaryColor,
            value: is2WheelRepairSelected,
            onChanged: (value) {
              setState(() {
                is2WheelRepairSelected = value!;
              });
            },
            title: Text("2-wheel Repair",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        )),
      ],
    );
  }

  Future<void> _getLocationUpdate() async {
    final Location locationcontroller = Location();
    LatLng? currentposition;

    bool _serviceEnabled;
    PermissionStatus permissionGranted;

    _serviceEnabled = await locationcontroller.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await locationcontroller.requestService();
    }

    permissionGranted = await locationcontroller.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationcontroller.requestPermission();
    }

    if (permissionGranted == PermissionStatus.granted) {
      locationcontroller.onLocationChanged
          .listen((LocationData currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          setState(() {
            currentposition =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
            // Call storeData method with the current position
            storeData(currentposition);
          });
        }
      });
    }
  }

  void storeData(LatLng? currentPosition) async {
    final ap = Provider.of<AuthorizationProvider>(context, listen: false);
    MechanicModel mechanicModel = MechanicModel(
      qualification: qualificationController.text.trim(),
      email: emailController.text.trim(),
      name: nameController.text.trim(),
      bio: bioController.text.trim(),
      phoneNumber: "",
      profilePic: "",
      createdAt: '',
      uid: '',
      is4WheelRepairSelected: is4WheelRepairSelected,
      is6WheelRepairSelected: is6WheelRepairSelected,
      is2WheelRepairSelected: is2WheelRepairSelected,
      isTowSelected: isTowSelected,
      latitude: currentPosition?.latitude,
      longitude: currentPosition?.longitude,
    );

    ap.saveMechanicDataToFirebase(
        context: context,
        OnSuccess: () {
          ap.saveMechanicDataToSP().then((value) => ap.setSignIn().then(
              (value) => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MechanicHomeScreen()),
                  (route) => false)));
        },
        mechanicModel: mechanicModel,
        profilePic: image!);
  }
}
