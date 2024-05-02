//import 'dart:html';

//import 'dart:ffi';

//import 'package:chat_app_3/models/message.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';
import '../models/request_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChatService();

  Stream<List<Map<String, dynamic>>> getMechanicsStream(selectedService) {
    return _firestore.collection("mechanic").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserRequestStream(String mechanicId) {
    return _firestore
        .collection("service_requests")
        .where("mechanicId", isEqualTo: mechanicId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final requestData = doc.data();
        if (requestData.isNotEmpty) {
          print("Request data available: $requestData");
        } else {
          print("No request data available");
        }
        return requestData;
      }).toList();
    });
  }

  Future<void> sendServiceRequest(
      {required String mechanicId,
      required String carName,
      required String picture,
      required String carId,
      required String problemDescription,
      required String year,
      required String fuel}) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      final String currentUserId = currentUser.uid;

      ServiceRequest newRequest = ServiceRequest(
        model: carName,
        mechanicId: mechanicId,
        carId: carId,
        problemDescription: problemDescription,
        year: year,
        fuel: fuel,
        manufacture: fuel,
        picture: picture,
      );

      List<String> ids = [currentUserId, mechanicId];
      ids.sort();
      String chatRoomID = ids.join('_');

      await _firestore
          .collection("service_requests")
          .doc(chatRoomID)
          .set(newRequest.toMap());
    } else {
      // Handle the case when the current user is null
      print("Error: Current user is null");
      // You can also show an error message to the user or take appropriate action
    }
  }

  Future<void> sendMessage(String receiverID, String message) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      final String currentUserID = currentUser.phoneNumber ?? '';
      final String currentUserEmail = currentUser.email ?? '';
      final Timestamp timestamp = Timestamp.now();

      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
      );

      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoomID = ids.join('_');

      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.toMap());
    } else {
      // Handle the case when the current user is null
      print("Error: Current user is null");
      // You can also show an error message to the user or take appropriate action
    }
  }

  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
