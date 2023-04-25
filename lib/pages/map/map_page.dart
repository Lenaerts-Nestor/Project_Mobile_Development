// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:provider/provider.dart';
import 'map_functions.dart';

String username = 'krupuks';
String tilesize = '256';
String scale = '2';
String mapboxAccessToken =
    'pk.eyJ1Ijoia3J1cHVrcyIsImEiOiJjbGd1a2Y4aDMyM2RpM2NtdDF0OWl5aXJyIn0.T-90bn65p10SjFwgfBiWyg';
String mapboxUrl =
    'https://api.mapbox.com/styles/v1/$username/clgukhlsf005g01o58vp31upm/tiles/$tilesize/{z}/{x}/{y}@${scale}x?access_token=$mapboxAccessToken';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _isAddingMarkers = false;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    getMarkersFromDatabase(context, (List<Marker> markers) {
      setState(() {
        _markers = markers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userLogged = Provider.of<UserLogged>(context);
    final userEmail = userLogged.email.trim();

    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(51.2172, 4.4212),
          zoom: 16,
          onTap: _isAddingMarkers
              ? (tapPosition, latlng) {
                  createMarker(latlng, userEmail, context, (Marker newMarker) {
                    setState(() {
                      _markers.add(newMarker);
                      _isAddingMarkers = false;
                    });
                  });
                }
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate: mapboxUrl,
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isAddingMarkers = !_isAddingMarkers;
          });
        },
        child: Icon(_isAddingMarkers ? Icons.cancel : Icons.add_location),
      ),
    );
  }
}
