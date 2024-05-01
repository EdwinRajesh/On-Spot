class CarModel {
  String manufacture;
  String model;
  List<String> carPictures; // Updated to a list of strings

  String? fuel;
  String? year;
  String? uid;

  CarModel({
    required this.manufacture,
    required this.model,
    required this.carPictures, // Updated parameter
    required this.fuel,
    required this.year,
    required this.uid,
  });

  // from map
  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      manufacture: map['manufacture'] ?? '',
      model: map['model'] ?? '',
      uid: map['uid'] ?? '',
      year: map['year'] ?? '',
      fuel: map['fuel'] ?? '',
      carPictures: List<String>.from(
          map['carPictures'] ?? []), // Update parsing to list of strings
    );
  }

  // to map
  Map<String, dynamic> toMap() {
    return {
      "manufacture": manufacture,
      "model": model,
      "uid": uid,
      "carPictures": carPictures, // Updated field name
      "year": year,
      "fuel": fuel,
    };
  }
}
