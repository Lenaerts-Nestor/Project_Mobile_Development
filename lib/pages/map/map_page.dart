// ignore_for_file: await_only_futures, unnecessary_null_comparison

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkflow/components/style/designStyle.dart';
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
  const MapPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _isAddingMarkers = false;
  List<Marker> _markers = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    //refresh de map elke seconde
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      await {removeExpiredMarkers(), updateMarkerState()};

      _updateMarkers();
    });
    _updateMarkers();
  }

  //zet de markers op de map van de database
  void _updateMarkers() {
    getMarkersFromDatabase(context, (List<Marker> markers) {
      setState(() {
        _markers = markers;
      });
    });
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userLogged = Provider.of<UserLogged>(context);
    return Scaffold(
      //voor het moment
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(51.2172, 4.4212),
          zoom: 16,
          maxZoom: 30,
          maxBounds: LatLngBounds(
            LatLng(51.18, 4.33), // southwest corner
            LatLng(51.25, 4.46), // northeast corner
          ),
          onTap: _isAddingMarkers
              ? (position, latlng) {
                  showPopupPark(context, latlng, userLogged.email);
                  createMarker(latlng, userLogged.email, context,
                      (Marker newMarker) {
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
            //om errors te voorkomen =>
            additionalOptions: {'accessToken': mapboxAccessToken},
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isAddingMarkers = !_isAddingMarkers;
          });
        },
        backgroundColor: color4,
        foregroundColor: color1,
        child: Icon(_isAddingMarkers ? Icons.cancel : Icons.add_location),
      ),
    );
  }
}
