import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parkflow/model/vehicle.dart';
import 'package:parkflow/pages/settings/pages/vehicles/set_vehicle_properties.dart';

class VehicleDropdown_brand extends StatelessWidget {
  final List<Vehicle> vehicles;
  final Vehicle selectedVehicle;
  final Function(Vehicle?) onChanged;

  const VehicleDropdown_brand({
    Key? key,
    required this.vehicles,
    required this.selectedVehicle,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Vehicle>(
      value: selectedVehicle,
      onChanged: onChanged,
      iconEnabledColor: Colors.black,
      items: vehicles.map((vehicle) {
        return DropdownMenuItem<Vehicle>(
          value: vehicle,
          child: SizedBox(
            width: double.infinity,
            child: Text(vehicle.brand),
          ),
        );
      }).toList(),
      selectedItemBuilder: (BuildContext context) {
        return vehicles.map<Widget>((Vehicle item) {
          return Row(
            children: [
              SizedBox(
                width: 24, // Adjust the size of the SVG icon
                height: 24,
                child: getSvg(item.brand, getColor(item.color)),
              ),
              SizedBox(
                width: 10,
              ),
              Text(item.model),
            ],
          );
        }).toList();
      },
    );
  }
}
