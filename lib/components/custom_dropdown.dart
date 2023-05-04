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

//dropdown merk van auto:
final List<String> brandList = [
  'Toyota',
  'Honda',
  'Volkswagen',
  'Ford',
  'Hyundai',
  'Kia',
  'Mazda',
  'Nissan',
  'Subaru',
  'Chevrolet',
];
//dropdown model van auto:

final Map<String, List<String>> modelList = {
  'Toyota': [
    'Corolla',
    'Camry',
    'RAV4',
  ],
  'Honda': [
    'Civic',
    'Accord',
    'CR-V',
  ],
  'Volkswagen': [
    'Golf',
    'Jetta',
    'Passat',
  ],
  'Ford': [
    'Fiesta',
    'Focus',
    'Mustang',
  ],
  'Hyundai': [
    'Elantra',
    'Sonata',
    'Tucson',
  ],
  'Kia': [
    'Rio',
    'Optima',
    'Sportage',
  ],
  'Mazda': [
    'CX-3',
    'CX-5',
    'Mazda3',
  ],
  'Nissan': [
    'Altima',
    'Maxima',
    'Rogue',
  ],
  'Subaru': [
    'Impreza',
    'Legacy',
    'Outback',
  ],
  'Chevrolet': [
    'Camaro',
    'Malibu',
    'Traverse',
  ],
};
//dropdown kleur van auto:
const List<String> colorList = [
  'Red',
  'Green',
  'Blue',
  'Yellow',
  'White',
  'Black',
];
