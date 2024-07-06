// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first/pages/mechanic_module/mechanic_map.dart';
import 'package:first/utils/register_textfield.dart';
import 'package:first/utils/secondary.dart';
import 'package:first/utils/user_tile.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../user_module/user_messaging.dart';

class SelectedUserFromMechanicInterface extends StatefulWidget {
  final double? latitude;
  final String userName;
  final String mechanicId;
  final double? longitude;
  final String userEmail;
  final String userPhoto;
  final String userId;
  const SelectedUserFromMechanicInterface(
      {super.key,
      required this.latitude,
      required this.longitude,
      required this.userEmail,
      required this.userPhoto,
      required this.userId,
      required this.userName,
      required this.mechanicId});

  @override
  State<SelectedUserFromMechanicInterface> createState() =>
      _SelectedUserFromMechanicInterfaceState();
}

class _SelectedUserFromMechanicInterfaceState
    extends State<SelectedUserFromMechanicInterface> {
  TextEditingController paymentController = TextEditingController();
  bool isFeeSent = false;
  String sentFee = '';
  bool isLoading = true;
  bool hasPaid = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchPaymentStatus() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('mechanic')
          .doc(widget.mechanicId)
          .collection('request_accept')
          .doc(widget.userId) // Replace with dynamic user ID
          .get();
      print(doc);
      if (doc.exists) {
        setState(() {
          hasPaid = doc['hasPaid'] == 'true';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Document does not exist');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              backgroundImage: NetworkImage(widget.userPhoto),
              radius: 22,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(widget.userName),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: secondaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MechanicMap(
                                latitude: widget.longitude ?? 0.0,
                                longitude: widget.latitude ?? 0.0,
                              ))),
                  child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 56, vertical: 16),
                      decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(8)),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "User Location",
                              style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.location_pin,
                              color: primaryColor,
                              size: 24,
                            )
                          ],
                        ),
                      )),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              UserTile(
                text: "Message",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverEmail: widget.userEmail,
                        receiverID: widget.userId,
                        profilePic: widget.userPhoto,
                        receiverName: widget.userName,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 24,
              ),
              paymentButton(),
              SizedBox(
                height: 24,
              ),
              hasPaid
                  ? Text("Payment received successfully")
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Container paymentButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: isFeeSent
          ? Center(
              child: Text(
                'Service fee sent: ₹$sentFee',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.black45,
                    fontWeight: FontWeight.bold),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: RegisterTextField(
                    hintText: 'Enter the service fee',
                    obscureText: false,
                    widgetController: paymentController,
                  ),
                ),
                SizedBox(width: 4),
                SecondaryButton(
                  text: "Send",
                  onPressed: () async {
                    String price = paymentController.text;
                    if (price.isNotEmpty) {
                      try {
                        // Update the document in the "request_accept" collection
                        await FirebaseFirestore.instance
                            .collection('mechanic')
                            .doc(widget.mechanicId)
                            .collection('request_accept')
                            .doc(widget.userId)
                            .set({
                          'serviceFee': price,
                        }, SetOptions(merge: true));

                        setState(() {
                          isFeeSent = true;
                          sentFee = price;
                        });

                        print('Price sent successfully');
                      } catch (e) {
                        print('Failed to send price: $e');
                      }
                    } else {
                      print('Price is empty');
                    }
                  },
                ),
              ],
            ),
    );
  }
}
