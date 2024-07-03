import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/car_model.dart';
import '../models/mechanic_model.dart';

import '../models/user_models.dart';
import '../pages/authentication_module/otp_screen.dart';
import '../utils/utils.dart';

class AuthorizationProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid!;

  late UserModel _userModel = UserModel(
    name: 'John Doe',
    email: 'john@example.com',
    createdAt: DateTime.now().toString(),
    phoneNumber: '1234567890',
    uid: 'user123',
    profilePic: '',
  );

  //late UserModel _userModel;
  UserModel get userModel => _userModel;

  late MechanicModel _mechanicModel;
  MechanicModel get mechanicModel => _mechanicModel;

  late CarModel _carModel;
  CarModel get carModel => _carModel;

  static final FirebaseAuth auth1 = FirebaseAuth.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthorizationProvider() {
    checkSignIn();
  }

//check Log in

  void checkSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signed_in") ?? false;
    notifyListeners();
  }

//set sign in
  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  //sign out
  Future userSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await auth.signOut();
    _isSignedIn = false;
    notifyListeners();
    s.clear();
  }

//register the phinoe number guys
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            await auth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (FirebaseAuthException error) {
            throw Exception(error.message);
          },
          codeSent: (String verificationId, int? forceResendingToken) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        OtpScreen(verificationId: verificationId)));
          },
          codeAutoRetrievalTimeout: (String verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

//otp verification
  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);
      User? user = (await auth.signInWithCredential(creds)).user!;

      _uid = user.phoneNumber;
      onSuccess();

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  //DATABASE OPERATIONS
  //*************************SAVE DATA TO FIREBASE*********************** */

  void saveMechanicDataToFirebase(
      {required BuildContext context,
      required File profilePic,
      required MechanicModel mechanicModel,
      required Function OnSuccess}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await storeFileToStorage("mechanic/profilePic/$_uid", profilePic)
          .then((value) {
        mechanicModel.profilePic = value;

        mechanicModel.createdAt =
            DateTime.now().millisecondsSinceEpoch.toString();
        mechanicModel.phoneNumber = auth.currentUser?.phoneNumber;
        mechanicModel.uid = auth.currentUser?.phoneNumber;
      });
      _mechanicModel = mechanicModel;

      //upload to db
      await store
          .collection('mechanic')
          .doc(_uid)
          .set(mechanicModel.toMap())
          .then((value) {
        OnSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  void saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required File profilePic,
    required Function OnSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await storeFileToStorage(
              "user/$_uid/profilePicture/${DateTime.now().millisecondsSinceEpoch}",
              profilePic)
          .then((value) {
        userModel.profilePic = value;
        userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
        userModel.phoneNumber = auth.currentUser?.phoneNumber;
        // Use Firebase Authentication UID as document ID
        // _uid = auth.currentUser?.uid;
        _uid = userModel.phoneNumber;
        userModel.uid = _uid;
      });
      _userModel = userModel;

      //upload to db
      await store
          .collection('users')
          .doc(_uid) // Use Firebase Authentication UID as document ID
          .set(userModel.toMap())
          .then((value) {
        OnSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  void saveCarDataToFirebase(
      {required BuildContext context,
      required List<File> carPictures, // Updated parameter to accept a list
      required CarModel carModel,
      required Function OnSuccess}) async {
    _isLoading = true;
    notifyListeners();
    _carModel = carModel;

    try {
      // Upload each car picture to storage
      List<String> uploadedPictureUrls = [];
      for (File picture in carPictures) {
        String pictureUrl = await storeFileToStorage(
          "user/$_uid/carPictures/${DateTime.now().millisecondsSinceEpoch}",
          picture,
        );
        uploadedPictureUrls.add(pictureUrl);
      }

      // Update carModel with list of picture URLs
      carModel.carPictures = uploadedPictureUrls;
      carModel.uid = auth.currentUser?.phoneNumber;

      // Upload carModel to Firestore
      await store
          .collection('users')
          .doc(_uid)
          .collection('user_car')
          .doc()
          .set(carModel.toMap())
          .then((value) {
        OnSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  //***************************DELETE CAR */

// ...

  Future<bool> deleteCarFromFirestore(String userId, CarModel car) async {
    try {
      // Get a reference to the Firestore collection 'users'
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Get a reference to the user document with the provided userId
      DocumentReference userDocRef = usersCollection.doc(userId);

      // Get a reference to the 'user_car' subcollection within the user document
      CollectionReference userCarCollection = userDocRef.collection('user_car');

      // Find the car document matching the provided CarModel object
      QuerySnapshot querySnapshot = await userCarCollection
          .where('manufacture', isEqualTo: car.manufacture)
          .where('model', isEqualTo: car.model)
          .where('year', isEqualTo: car.year)
          .where('fuel', isEqualTo: car.fuel)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot carDocSnapshot = querySnapshot.docs.first;

        await carDocSnapshot.reference.delete();

        return true;
      } else {
        print('No matching car found for deletion');
        return false;
      }
    } catch (e) {
      print('Error deleting car: $e');

      return false;
    }
  }

  //*************************GET DATA FROM FIRESTORE

  Future getDataFromFirestore() async {
    await store
        .collection("users")
        .doc(auth.currentUser!.phoneNumber)
        .get()
        .then((DocumentSnapshot snapshot) {
      _userModel = UserModel(
        name: snapshot['name'],
        email: snapshot['email'],
        createdAt: snapshot['createdAt'],
        profilePic: snapshot['profilePic'],
        uid: snapshot['uid'],
        phoneNumber: snapshot['phoneNumber'],
      );
      _uid = snapshot['phoneNumber'];
    });
  }

  Future<List<CarModel>> getCarDataFromFirestore() async {
    List<CarModel> carList = [];
    try {
      QuerySnapshot querySnapshot = await store
          .collection('users')
          .doc(_uid)
          .collection('user_car')
          .get();
      querySnapshot.docs.forEach((DocumentSnapshot snapshot) {
        CarModel carModel = CarModel(
          manufacture: snapshot['manufacture'],
          carPictures: List<String>.from(
              snapshot['carPictures']), // Updated to parse list of strings
          fuel: snapshot['fuel'],
          model: snapshot['model'],
          year: snapshot['year'],
          uid: snapshot['uid'],
        );
        _uid = carModel.uid;
        carList.add(carModel);
      });

      // Initialize _carModel with the first item in the list if it's not empty
      if (carList.isNotEmpty) {
        _carModel = carList.first;
      } else {
        print("no store car found");
        throw Exception('No car data found');
      }
    } catch (e) {
      print('Error fetching car data from Firestore: $e');
    }
    return carList;
  }

  Future<void> getMechanicDataFromFirestore() async {
    await store
        .collection("mechanic")
        .doc(auth.currentUser!.phoneNumber)
        .get()
        .then((DocumentSnapshot snapshot) {
      _mechanicModel = MechanicModel(
        bio: snapshot['bio'],
        name: snapshot['name'],
        email: snapshot['email'],
        createdAt: snapshot['createdAt'],
        profilePic: snapshot['profilePic'],
        qualification: snapshot['qualification'],
        uid: snapshot['uid'],
        phoneNumber: snapshot['phoneNumber'],
        is4WheelRepairSelected: snapshot['is4WheelRepairSelected'],
        is2WheelRepairSelected: snapshot['is2WheelRepairSelected'],
        is6WheelRepairSelected: snapshot['is6WheelRepairSelected'],
        isTowSelected: snapshot['isTowSelected'],
        latitude: snapshot['latitude'],
        longitude: snapshot['longitude'],
      );
      _uid = mechanicModel.uid;
    });
  }

  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

//************************ CHECK USER AND MECHANIC EXISTS */
  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot = await store
        .collection("users")
        .doc(auth.currentUser?.phoneNumber)
        .get();

    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkExistingMechanic() async {
    DocumentSnapshot snapshot = await store
        .collection("mechanic")
        .doc(auth.currentUser?.phoneNumber)
        .get();
    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  //****************     SHARED PREFERENCES   ***************/

  Future saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("user_model", jsonEncode(userModel.toMap()));
  }

  Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("user_model") ?? "";
    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel.uid;
    notifyListeners();
  }

  Future saveMechanicDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("mechanic_model", jsonEncode(mechanicModel.toMap()));
  }

  Future getMechanicDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("mechanic_model") ?? "";
    _mechanicModel = MechanicModel.fromMap(jsonDecode(data));
    _uid = _mechanicModel.uid;
    notifyListeners();
  }

  Future<void> saveCarDataToSP(List<CarModel> carList) async {
    SharedPreferences s = await SharedPreferences.getInstance();
    // Convert the list of CarModel objects to JSON strings
    List<String> jsonList =
        carList.map((car) => jsonEncode(car.toMap())).toList();
    // Save the JSON list to shared preferences
    await s.setStringList("car_list", jsonList);
  }

  Future<List<CarModel>> getCarDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    List<String>? jsonList = s.getStringList("car_list");
    if (jsonList != null) {
      List<CarModel> carList =
          jsonList.map((json) => CarModel.fromMap(jsonDecode(json))).toList();
      if (carList.isNotEmpty) {
        _carModel = carList.first;
        _uid = _carModel.uid;
        notifyListeners();
        print("Sharde Preference found car");
      }
      return carList;
    } else {
      print("Sharde Preference no car");
      // Return an empty list or null
      return [];
    }
  }
}
