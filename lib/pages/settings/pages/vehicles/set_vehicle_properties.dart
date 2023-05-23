import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture getSvg(String brandName, Color color) {
  switch (brandName) {
    case 'Mercedes':
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/mercedes.svg',
        color: color,
      );
    case 'Honda':
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/honda.svg',
        color: color,
      );
    case 'Audi':
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/audi.svg',
        color: color,
      );
    case 'BMW':
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/bmw.svg',
        color: color,
      );
    case 'Citroen':
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/citroen.svg',
        color: color,
      );
    case 'Ford':
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/ford.svg',
        color: color,
      );
    case 'Porsche':
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/porsche.svg',
        color: color,
      );
    case 'Renault':
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/renault.svg',
        color: color,
      );
    case 'Toyota':
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/toyota.svg',
        color: color,
      );
    case 'Volkswagen':
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/volkswagen.svg',
        color: color,
      );
    
    default:
      return SvgPicture.asset(
        'assets/vehicle_brands_icons/default.svg',
        color: color,
      );
  }
}

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
