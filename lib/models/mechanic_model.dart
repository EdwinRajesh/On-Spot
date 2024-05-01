class MechanicModel {
  String name;
  String email;
  String profilePic;
  String qualification;
  String createdAt;
  String? phoneNumber;
  String? uid;
  final String bio;
  final double? latitude; // Add latitude field
  final double? longitude;
  final bool is4WheelRepairSelected;
  final bool is6WheelRepairSelected;
  final bool is2WheelRepairSelected;
  final bool isTowSelected;

  MechanicModel({
    required this.bio,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.phoneNumber,
    required this.uid,
    required this.profilePic,
    required this.qualification,
    required this.is4WheelRepairSelected,
    required this.is6WheelRepairSelected,
    required this.is2WheelRepairSelected,
    required this.isTowSelected,
  });

  // from map
  factory MechanicModel.fromMap(Map<String, dynamic> map) {
    return MechanicModel(
      bio: map['bio'],
      longitude: map['longitude'],
      latitude: map['latitude'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: map['createdAt'] ?? '',
      profilePic: map['profilePic'] ?? '',
      qualification: map['qualification'] ?? '',
      is4WheelRepairSelected: map['is4WheelRepairSelected'] ?? false,
      is6WheelRepairSelected: map['is6WheelRepairSelected'] ?? false,
      is2WheelRepairSelected: map['is2WheelRepairSelected'] ?? false,
      isTowSelected: map['isTowSelected'] ?? false,
    );
  }

  // to map
  Map<String, dynamic> toMap() {
    return {
      "bio": bio,
      "longitude": longitude,
      "latitude": latitude,
      "qualification": qualification,
      "name": name,
      "email": email,
      "profilePic": profilePic,
      "uid": uid,
      "phoneNumber": phoneNumber,
      "createdAt": createdAt,
      "is4WheelRepairSelected": is4WheelRepairSelected,
      "is6WheelRepairSelected": is6WheelRepairSelected,
      "is2WheelRepairSelected": is2WheelRepairSelected,
      "isTowSelected": isTowSelected,
    };
  }
}
