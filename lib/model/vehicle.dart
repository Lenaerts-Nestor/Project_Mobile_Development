class Vehicle {
  final String licensePlate;
  final String address;

  Vehicle({
    required this.licensePlate,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        'licensePlate': licensePlate,
        'address': address,
      };

  static Vehicle fromJson(Map<String, dynamic> json) => Vehicle(
        licensePlate: json['licensePlate'] as String,
        address: json['address'] as String,
      );
}
