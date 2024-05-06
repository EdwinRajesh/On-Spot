class MechanicResponse {
  final double? latitude; // Add latitude field
  final double? longitude;
  final String mechanicId;
  final String profilePic;
  final String name;
  MechanicResponse({
    required this.longitude,
    required this.mechanicId,
    required this.profilePic,
    required this.name,
    required this.latitude,
  });
  Map<String, dynamic> toMap() {
    return {
      'latitude': longitude,
      'longitude': latitude,
      'profilePic': profilePic,
      'name': name,
      'mechanicId': mechanicId,
    };
  }
}
