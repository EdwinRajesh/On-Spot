// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first/pages/user_module/user_cards/user_nav_screen.dart';
import 'package:first/utils/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../utils/colors.dart';
import '../../utils/user_tile.dart';
import '../../utils/utils.dart';
import 'user_messaging.dart';

class SelectedMechanicScreen extends StatefulWidget {
  final String mechanicName;
  final String mechanicProfilePicture;
  final String mechanicId;
  final String mechanicEmail;
  const SelectedMechanicScreen(
      {super.key,
      required this.mechanicName,
      required this.mechanicProfilePicture,
      required this.mechanicId,
      required this.mechanicEmail});

  @override
  State<SelectedMechanicScreen> createState() => _SelectedMechanicScreenState();
}

class _SelectedMechanicScreenState extends State<SelectedMechanicScreen> {
  String serviceFee = '';
  bool isLoading = true;
  Razorpay _razorpay = Razorpay();
  bool hasPaid = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _fetchServiceFee() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('mechanic')
          .doc(widget.mechanicId)
          .collection('request_accept')
          .doc(auth.currentUser!.phoneNumber)
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
          .doc(auth.currentUser!.phoneNumber)
          .update({'feeSent': status});
    } catch (e) {
      print('Error updating service fee status: $e');
    }
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
                  text: 'close',
                  onPressed: () async {
                    FirebaseAuth auth = FirebaseAuth.instance;
                    try {
                      await FirebaseFirestore.instance
                          .collection('mechanic')
                          .doc(widget.mechanicId)
                          .collection('request_accept')
                          .doc(auth.currentUser
                              ?.phoneNumber) // Replace with the document ID you want to delete
                          .delete();

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserNavPage(
                            index: 1,
                          ),
                        ),
                      );

                      showSnackBar(context, "communication channel closed");

                      print('Document deleted successfully.');
                    } catch (e) {
                      print('Error deleting document: $e');
                    }
                  }),
            ),
          )
        ],
      ),
    );
  }
}
