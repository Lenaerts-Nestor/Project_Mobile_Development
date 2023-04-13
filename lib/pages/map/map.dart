// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

//error => naar hier [https://docs.fleaflet.dev/usage/basics ]
//toekomst => https://pub.dev/packages/material_floating_search_bar,
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool shownavigationBar = false;
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(51.2172, 4.4212),
        zoom: 17,
      ),
      children: [
        TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c']),
      ],
    );
  }
}
