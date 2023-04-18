class Vehicle {
  final String licensePlate;
  final String brand;
  final String color;

  Vehicle({
    required this.licensePlate,
    required this.brand,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'NummerPlaat': licensePlate,
        'brand': brand,
        'kleur': color,
      };

  static Vehicle fromJson(Map<String, dynamic> json) => Vehicle(
        licensePlate: json['NummerPlaat'] as String,
        brand: json['brand'] as String,
        color: json['kleur'] as String,
      );
}
