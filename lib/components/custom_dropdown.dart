import 'package:flutter/material.dart';

class VehicleDropdown extends StatelessWidget {
  final List<String> items;
  final String value;
  final Function(String?) onChanged;

  const VehicleDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      onChanged: onChanged,
      iconEnabledColor: Colors.black,
      items: items.map((valueOfItem) {
        return DropdownMenuItem<String>(
          value: valueOfItem,
          child: Text(valueOfItem),
        );
      }).toList(),
    );
  }
}
//mercedes, citroen, audi, renault, volkswagen, porche, honda, toyota, ford, hyundai.

final List<String> brandList = [
  'Toyota',
  'Mercedes',
  'Citroën',
  'Audi',
  'Renault',
  'Volkswagen',
  'Porsche',
  'Honda',
  'Ford',
  'BMW',
];

final Map<String, List<String>> modelList = {
  'Toyota': ['Camry', 'Corolla', 'RAV4'],
  'Mercedes': ['C-Class', 'E-Class', 'S-Class'],
  'Citroën': ['C3', 'C4', 'C5'],
  'Audi': ['A3', 'A4', 'Q5'],
  'Renault': ['Clio', 'Megane', 'Captur'],
  'Volkswagen': ['Golf', 'Passat', 'Tiguan'],
  'Porsche': ['911', 'Panamera', 'Cayenne'],
  'Honda': ['Civic', 'Accord', 'CR-V'],
  'Ford': ['Focus', 'Fiesta', 'Mustang'],
  'BMW': ['3 Series', '5 Series', 'X5'],
};
//dropdown kleur van auto:
const List<String> colorList = [
  'Rood',
  'Groen',
  'Blauw',
  'Geel',
  'Wit',
  'Zwart',
  'Grijs'
];
