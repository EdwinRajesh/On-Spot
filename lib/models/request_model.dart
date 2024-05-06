class ServiceRequest {
  final String problemDescription;
  final String picture;
  final String carId;
  final double? latitude; // Add latitude field
  final double? longitude;
  final String model;
  final String mechanicId;
  final String fuel;
  final String year;
  final String manufacture;

  ServiceRequest({
    required this.latitude,
    required this.longitude,
    required this.fuel,
    required this.year,
    required this.picture,
    required this.problemDescription,
    required this.carId,
    required this.mechanicId,
    required this.manufacture,
    required this.model,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': longitude,
      'longitude': latitude,
      'problemDescription': problemDescription,
      'picture': picture,
      'fuel': fuel,
      'year': year,
      'manufacture': manufacture,
      'carId': carId,
      'mechanicId': mechanicId,
      'model': model
    };
  }
}
