class Vehicle {
  final String model;
  final String brand;
  final String color;

  Vehicle({
    required this.model,
    required this.brand,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'model': model,
        'brand': brand,
        'kleur': color,
      };

  static Vehicle fromJson(Map<String, dynamic> json) => Vehicle(
        model: json['model'] as String,
        brand: json['brand'] as String,
        color: json['kleur'] as String,
      );
}
