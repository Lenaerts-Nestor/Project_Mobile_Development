import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

//op basis van de input zal dit de image geven van de gewenste brand.
SvgPicture getSvg(String brandName, Color color) {
  switch (brandName) {
    case 'Mercedes':
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/mercedes.svg',
        color: color,
      );
    case 'Honda':
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/bmw.svg',
        color: color,
      );
    // Add more cases for other vehicle brands and their respective SVG paths

    default:
      return SvgPicture.asset(
        'assets/default_vehicle_icon.svg',
        color: color,
      );
  }
}

//zal de kleur terug geven op basis van de parameter.
Color getColor(String colorName) {
  switch (colorName) {
    case 'Rood':
      return Colors.red;
    case 'Groen':
      return Colors.green;
    case 'Blauw':
      return Colors.blue;
    case 'Geel':
      return Colors.yellow;
    case 'Wit':
      return Colors.white;
    case 'Zwart':
      return Colors.black;
    case 'Grijs':
      return Colors.grey;
    default:
      return Colors.lightGreen;
  }
}
