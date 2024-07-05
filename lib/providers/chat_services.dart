//import 'dart:html';

//import 'dart:ffi';

//import 'package:chat_app_3/models/message.dart';

// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first/models/mechanic_accept_model.dart';

import '../models/message_model.dart';
import '../models/request_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChatService();

  Stream<List<Map<String, dynamic>>> getMechanicsStream(
      String selectedService) {
    return _firestore.collection("mechanic").snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.data()[selectedService] == true)
          .map((doc) => doc.data())
          .toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getSelectedMechanicStream() {
    return _firestore.collection("mechanic").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<List<String>> getMechanicUIDs(String userPhoneNumber) async {
    final List<String> mechanicUIDs = [];
    print("Current user phone numbr $userPhoneNumber");

    final QuerySnapshot<Map<String, dynamic>> mechanicsSnapshot =
        await FirebaseFirestore.instance.collection('mechanic').get();

    for (final mechanicDoc in mechanicsSnapshot.docs) {
      final QuerySnapshot<Map<String, dynamic>> serviceRequestsSnapshot =
          await mechanicDoc.reference.collection('service_requests').get();

      for (final serviceRequestDoc in serviceRequestsSnapshot.docs) {
        final String carId = serviceRequestDoc.id;
        if (carId == userPhoneNumber) {
          mechanicUIDs.add(mechanicDoc.id);
          break; // Once a match is found, no need to check further for this mechanic
        }
      }
    }

    return mechanicUIDs;
  }

  Future<List<String>> getAcceptedMechanicUIDs(String userPhoneNumber) async {
    final List<String> mechanicUIDs = [];
    print("Current user phone numbr $userPhoneNumber");

    final QuerySnapshot<Map<String, dynamic>> mechanicsSnapshot =
        await FirebaseFirestore.instance.collection('mechanic').get();

    for (final mechanicDoc in mechanicsSnapshot.docs) {
      final QuerySnapshot<Map<String, dynamic>> serviceRequestsSnapshot =
          await mechanicDoc.reference.collection('request_accept').get();

      for (final serviceRequestDoc in serviceRequestsSnapshot.docs) {
        final String carId = serviceRequestDoc.id;
        if (carId == userPhoneNumber) {
          mechanicUIDs.add(mechanicDoc.id);
          break; // Once a match is found, no need to check further for this mechanic
        }
      }
    }

    return mechanicUIDs;
  }

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getAcceptedUserStream(String mechanicId) {
    try {
      CollectionReference<Map<String, dynamic>> mechanicRef = FirebaseFirestore
          .instance
          .collection('mechanic')
          .doc(mechanicId)
          .collection('request_accept');

      return mechanicRef.snapshots().map((snapshot) {
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
    } catch (error) {
      // Handle errors
      print('Error retrieving service requests: $error');
      return Stream.empty(); // Return an empty stream in case of error
    }
  }

  Stream<List<Map<String, dynamic>>> getUserRequestStream(String mechanicId) {
    try {
      CollectionReference<Map<String, dynamic>> mechanicRef = FirebaseFirestore
          .instance
          .collection('mechanic')
          .doc(mechanicId)
          .collection('service_requests');

      return mechanicRef.snapshots().map((snapshot) {
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
    } catch (error) {
      // Handle errors
      print('Error retrieving service requests: $error');
      return Stream.empty(); // Return an empty stream in case of error
    }
  }

  Future<void> SendMechanicResponse({
    required String problemDescription,
    required String userName,
    required String model,
    required String manufacture,
    required String mechanicId,
    required double longitude,
    required double latitude,
    required String profilePic,
    required String name,
    required String userId,
    required String fuel,
    required String year,
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      MechanicResponse mechanicResponse = MechanicResponse(
          problemDescription: problemDescription,
          longitude: longitude,
          mechanicId: mechanicId,
          profilePic: profilePic,
          name: name,
          latitude: latitude,
          userId: userId,
          userName: userName,
          model: model,
          manufacture: manufacture,
          fuel: fuel,
          year: year);
      String chatRoomID = userId;

      await _firestore
          .collection('mechanic')
          .doc(mechanicId)
          .collection("request_accept")
          .doc(chatRoomID)
          .set(mechanicResponse.toMap());
    } else {
      // Handle the case when the current user is null
      print("Error: Current user is null");
      // You can also show an error message to the user or take appropriate action
    }
  }

  Future<void> sendServiceRequest(
      {required String mechanicId,
      required double latitude,
      required double longitude,
      required String carName,
      required String picture,
      required String carId,
      required String problemDescription,
      required String year,
      required String fuel}) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      ServiceRequest newRequest = ServiceRequest(
        model: carName,
        mechanicId: mechanicId,
        carId: carId,
        problemDescription: problemDescription,
        year: year,
        fuel: fuel,
        manufacture: fuel,
        picture: picture,
        latitude: longitude,
        longitude: latitude,
      );

      String chatRoomID = currentUser.phoneNumber!;

      await _firestore
          .collection('mechanic')
          .doc(mechanicId)
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
