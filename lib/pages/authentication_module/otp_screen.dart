// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../mechanic_module/mechanic_home.dart';
import '../user_module/user_cards/user_nav_screen.dart';
import 'profile_selection_page.dart';

import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/button.dart';
import '../../utils/colors.dart';
import '../../utils/utils.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpCode;

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthorizationProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child: isLoading == true
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SafeArea(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Icon(Icons.arrow_back),
                            ),
                          ),
                          Text(
                            'Verification',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Enter the OTP sent to your phone number',
                            style: TextStyle(
                              fontSize: 16,
                              color: secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 24),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Pinput(
                              length: 6,
                              showCursor: true,
                              keyboardType: TextInputType.number,
                              defaultPinTheme: PinTheme(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: primaryColor),
                                ),
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onCompleted: (value) {
                                setState(() {
                                  otpCode = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 24),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 56),
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: CustomButton(
                                text: 'Verify',
                                onPressed: () {
                                  if (otpCode != null) {
                                    verifyOtp(context, otpCode!,
                                        widget.verificationId);
                                  } else {
                                    showSnackBar(context, "Enter 6-Digit code");
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          // Text('Didn\'t receive any code?',
                          //     style: TextStyle(
                          //         fontSize: 14,
                          //         fontWeight: FontWeight.bold,
                          //         color: Colors.black38)),
                          // SizedBox(height: 24),
                          // Text('Resend new code',
                          //     style: TextStyle(
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.bold,
                          //         color: primaryColor)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void verifyOtp(BuildContext context, String otpCode, String verificationId) {
    final ap = Provider.of<AuthorizationProvider>(context, listen: false);
    ap.verifyOtp(
      context: context,
      verificationId: verificationId,
      userOtp: otpCode,
      onSuccess: () {
        ap.checkExistingUser().then((value) => {
              if (value == true)
                {
                  ap.getDataFromFirestore().then((value) {
                    ap.saveUserDataToSP().then((value) {
                      ap.getCarDataFromFirestore().then((carList) {
                        print(carList);
                        ap.saveCarDataToSP(carList).then((value) {
                          ap.setSignIn().then((value) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserNavPage(
                                  index: 1,
                                ),
                              ),
                              (route) => false,
                            );
                            //});
                          });
                        });
                      });
                    });
                  })
                }
              else
                {
                  ap.checkExistingMechanic().then((value) => {
                        if (value == true)
                          {
                            ap.getMechanicDataFromFirestore().then((value) => ap
                                .saveMechanicDataToSP()
                                .then((value) => ap.setSignIn().then(
                                      (value) => Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MechanicHomeScreen(),
                                          ),
                                          (route) => false),
                                    )))
                          }
                        else
                          {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileSelectionPage()))
                          }
                      })
                }
            });
      },
    );
  }
}
