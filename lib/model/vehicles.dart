class Vehicle {
  final String licensePlate;

  Vehicle({required this.licensePlate});

  Map<String, dynamic> toJson() => {'licensePlate': licensePlate};

  static Vehicle fromJson(Map<String, dynamic> json) =>
      Vehicle(licensePlate: json['licensePlate']);
}
