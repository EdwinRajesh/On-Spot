// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import 'welcome.dart';
import '../../providers/auth_provider.dart' as MyAppAuthorizationProvider;
import 'package:provider/provider.dart';

import '../../utils/button.dart';
import '../../utils/colors.dart';
import '../../utils/utils.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController phoneController = TextEditingController();

  bool isValidPhone = false;

  void updateValidity() {
    setState(() {
      isValidPhone =
          phoneController.text.length == 10 && isNumeric(phoneController.text);
    });
  }

  bool isNumeric(String text) {
    RegExp numericRegex = RegExp(r'^[0-9]+$');
    return numericRegex.hasMatch(text);
  }

  void sendPhoneNumber() {
    final ap = Provider.of<MyAppAuthorizationProvider.AuthorizationProvider>(
        context,
        listen: false);
    String phoneNumber = phoneController.text.trim();
    ap.signInWithPhone(context, "+91$phoneNumber");
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthorizationProvider>(context, listen: true).isLoading;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WelcomePage()));
            },
            icon: Icon(
              Icons.arrow_back,
              color: secondaryColor,
            )),
      ),
      body: SafeArea(
        child: isLoading == true
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Registration',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add your phone number. We\'ll send you an authentication code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 24),
                      textField(),
                      SizedBox(height: 32),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: registerButton(context),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 26.0),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     // ignore: prefer_const_literals_to_create_immutables
                      //     children: [
                      //       Text(
                      //         "Have an account?",
                      //         style: TextStyle(
                      //           fontSize: 18,
                      //           color: Colors.black38,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //       SizedBox(
                      //         width: 8,
                      //       ),
                      //       GestureDetector(
                      //         onTap: () {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) => LoginPage()));
                      //         },
                      //         child: Text(
                      //           'Sign In',
                      //           style: TextStyle(
                      //             fontSize: 18,
                      //             color: primaryColor,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Padding textField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextFormField(
        keyboardType: TextInputType.phone,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        controller: phoneController,
        cursorColor: primaryColor,
        onChanged: (value) {
          updateValidity();
        },
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 11.0, 8.0, 0),
            child: Text(
              '+91',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor),
            ),
          ),
          suffixIcon: isValidPhone
              ? Icon(
                  Icons.check_circle,
                  color: primaryColor,
                  size: 32,
                )
              : null,
          hintText: "Enter phone number",
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
      ),
    );
  }

  Padding registerButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CustomButton(
        text: 'Register',
        onPressed: () {
          isValidPhone
              ? sendPhoneNumber()
              : showSnackBar(context, "Invalid Number");
        },
      ),
    );
  }
}
