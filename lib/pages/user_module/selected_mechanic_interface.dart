import 'package:first/pages/user_module/user_home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:first/utils/button.dart';
import 'package:first/utils/colors.dart';

import 'package:first/utils/user_tile.dart';

import 'user_messaging.dart';

class SelectedMechanicScreen extends StatefulWidget {
  final String mechanicName;
  final String mechanicProfilePicture;
  final String mechanicId;
  final String mechanicEmail;

  const SelectedMechanicScreen({
    Key? key,
    required this.mechanicName,
    required this.mechanicProfilePicture,
    required this.mechanicId,
    required this.mechanicEmail,
  }) : super(key: key);

  @override
  State<SelectedMechanicScreen> createState() => _SelectedMechanicScreenState();
}

class _SelectedMechanicScreenState extends State<SelectedMechanicScreen> {
  String serviceFee = '';
  bool isLoading = true;
  Razorpay _razorpay = Razorpay();
  bool hasPaid = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _externalWallet);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _paymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _paymentFailure);
    _fetchServiceFee();
  }

  @override
  void dispose() {
    _razorpay.clear(); // Dispose the Razorpay instance when not needed
    super.dispose();
  }

  void _paymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "Payment successful: ${response.paymentId}",
        timeInSecForIosWeb: 4);
    // Update Firestore with the service fee status
    _updateServiceFeeStatus(true);
    _savePaymentStatus(true);
  }

  void _paymentFailure(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "Payment failed: ${response.code} - ${response.message}",
        timeInSecForIosWeb: 4);
    // Update Firestore with the service fee status
    _updateServiceFeeStatus(false);
  }

  void _externalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "External wallet selected: ${response.walletName}",
        timeInSecForIosWeb: 4);
  }

  void makePayment() async {
    var options = {
      'key': 'rzp_test_LHmm4k8DuraSma',
      'amount': int.parse(serviceFee) * 100, // Amount in paise
      'name': widget.mechanicName,
      'description': 'Service fee payment',
      'prefill': {'contact': "9605642345", 'email': widget.mechanicEmail},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Method to save payment status to SharedPreferences
  Future<void> _savePaymentStatus(bool status) async {
    await _prefs.setBool('hasPaid', true);
  }

  Future<void> _fetchServiceFee() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('mechanic')
          .doc(widget.mechanicId)
          .collection('request_accept')
          .doc(auth.currentUser!.phoneNumber!)
          .get();

      if (doc.exists) {
        setState(() {
          serviceFee = doc['serviceFee'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching service fee: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateServiceFeeStatus(bool status) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      await FirebaseFirestore.instance
          .collection('mechanic')
          .doc(widget.mechanicId)
          .collection('request_accept')
          .doc(auth.currentUser!.phoneNumber!)
          .update({'feeSent': status});
    } catch (e) {
      print('Error updating service fee status: $e');
    }
  }

  void _showRatingDialog(BuildContext context) {
    int _rating = 1; // Default rating
    double _dragPosition = 0.0;
    double _dragPercentage = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _dragPosition += details.primaryDelta!;
                  _dragPercentage = _dragPosition / MediaQuery.of(context).size.height;
                });
              },
              onVerticalDragEnd: (details) {
                if (_dragPercentage > 0.5) {
                  Navigator.of(context).pop();
                  // Submit the rating to Firestore
                  FirebaseFirestore.instance
                      .collection('mechanic')
                      .doc(widget.mechanicId)
                      .collection('ratings')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .set({
                    'rating': _rating,
                    'ratedAt': DateTime.now(),
                  }).then((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserHomeScreen(),
                      ),
                    );
                  });
                } else {
                  setState(() {
                    _dragPosition = 0.0;
                    _dragPercentage = 0.0;
                  });
                }
              },
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Rate Mechanic', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 16.0),
                      Text('Rate from 1 to 5:', style: TextStyle(fontSize: 18)),
                      Slider(
                        value: _rating.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _rating.toString(),
                        onChanged: (double value) {
                          setState(() {
                            _rating = value.toInt();
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Submit the rating to Firestore
                          FirebaseFirestore.instance
                              .collection('mechanic')
                              .doc(widget.mechanicId)
                              .collection('ratings')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .set({
                            'rating': _rating,
                            'ratedAt': DateTime.now(),
                          }).then((_) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserHomeScreen(),
                              ),
                            );
                          });
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              backgroundImage: NetworkImage(widget.mechanicProfilePicture),
              radius: 22,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              widget.mechanicName,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: secondaryColor,
        foregroundColor: primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          UserTile(
            text: widget.mechanicName,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverEmail: widget.mechanicEmail,
                    receiverID: widget.mechanicId,
                    profilePic: widget.mechanicProfilePicture,
                    receiverName: widget.mechanicName,
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            height: 16,
          ),
          isLoading
              ? CircularProgressIndicator()
              : serviceFee.isNotEmpty
                  ? hasPaid
                      ? Text(
                          'Payment completed',
                          style: TextStyle(fontSize: 20, color: primaryColor),
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Service fee: ₹$serviceFee',
                                style: TextStyle(
                                    fontSize: 22, color: primaryColor),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                FirebaseAuth auth = FirebaseAuth.instance;
                                makePayment();
                                Future.delayed(
                                  Duration(seconds: 10),
                                  () {
                                    setState(() {
                                      hasPaid = true;
                                    });
                                  },
                                );
                                _savePaymentStatus(true);
                                await FirebaseFirestore.instance
                                    .collection('mechanic')
                                    .doc(widget.mechanicId)
                                    .collection('request_accept')
                                    .doc(auth.currentUser?.phoneNumber!)
                                    .set({
                                  'hasPaid': true,
                                }, SetOptions(merge: true));
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(primaryColor),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white),
                              ),
                              child: const Text(
                                'Pay',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No service fee sent yet',
                        style: TextStyle(fontSize: 22, color: Colors.red),
                      ),
                    ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 96),
            child: Container(
              child: CustomButton(
                text: 'Close',
                onPressed: () async {
                  _showRatingDialog(context);
                  FirebaseAuth auth = FirebaseAuth.instance;
                  try {
                    await FirebaseFirestore.instance
                        .collection('mechanic')
                        .doc(widget.mechanicId)
                        .collection('request_accept')
                        .doc(auth.currentUser?.phoneNumber!)
                        .delete();

                    print('Document deleted successfully.');
                  } catch (e) {
                    print('Error deleting document: $e');
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

