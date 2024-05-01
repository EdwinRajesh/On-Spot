class ServiceRequest {
  final String problemDescription;
  final String carId;
  final String carName;
  final String mechanicId;

  ServiceRequest({
    required this.problemDescription,
    required this.carId,
    required this.mechanicId,
    required this.carName,
  });

  Map<String, dynamic> toMap() {
    return {
      'problemDescription': problemDescription,
      'carId': carId,
      'mechanicId': mechanicId,
      'carName': carName
    };
  }
}
