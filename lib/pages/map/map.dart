import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

//error => naar hier [https://docs.fleaflet.dev/usage/basics ]
//toekomst => https://pub.dev/packages/material_floating_search_bar,
class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(51.2172, 4.4212),
        //aangezien we niet gaan user location gebruiken maar een vaste plaats. we pakken central station.
        zoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(51.2172, 4.4212),
              width: 80,
              height: 80,
              builder: (context) => GestureDetector(
                onTap: () {
                  //werkt :D
                  print('der is geklicked');
                },
                child: const Icon(
                  Icons.ac_unit_outlined,
                  size: 30,
                  color: Colors.yellow,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
