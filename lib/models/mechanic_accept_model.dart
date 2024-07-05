class MechanicResponse {
  final double? latitude; // Add latitude field
  final double? longitude;
  final String mechanicId;
  final String profilePic;
  final String userId;
  final String name;
  final String problemDescription;
  final String userName;
  final String model;
  final String manufacture;
  final String fuel;
  final String year;

  MechanicResponse({
    required this.userName,
    required this.model,
    required this.manufacture,
    required this.fuel,
    required this.year,
    required this.problemDescription,
    required this.userId,
    required this.longitude,
    required this.mechanicId,
    required this.profilePic,
    required this.name,
    required this.latitude,
  });
  Map<String, dynamic> toMap() {
    return {
      'problemDescription': problemDescription,
      'model': model,
      'manufacture': manufacture,
      'userName': userName,
      'fuel': fuel,
      'year': year,
      'latitude': longitude,
      'longitude': latitude,
      'profilePic': profilePic,
      'name': name,
      'mechanicId': mechanicId,
      'userId': userId,
    };
  }
}
