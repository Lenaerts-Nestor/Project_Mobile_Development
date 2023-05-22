// ignore_for_file: await_only_futures, unnecessary_null_comparison

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:parkflow/pages/map/functions/popUps/parking_function.dart';
import 'package:provider/provider.dart';
import 'functions/markers/marker_functions.dart';

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
  double? currentLatitude;
  double? currentLongitude;

  @override
  void initState() {
    super.initState();
    //refresh de map elke seconde
    _determinePosition();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      updateMarkerState();

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

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();

    // Store the latitude and longitude values in the variables
    currentLatitude = position.latitude;
    currentLongitude = position.longitude;

    return position;
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
    bool isVisible = false;

    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(51.2172, 4.4212),
          zoom: 16,
          maxZoom: 30,
          // maxBounds: LatLngBounds(
          //   LatLng(51.18, 4.33), // southwest corner
          //   LatLng(51.25, 4.46), // northeast corner
          // ),
          onTap: _isAddingMarkers
              ? (position, latlng) {
                  showPopupPark(context, latlng, userLogged.email);
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
          showPopupPark(context, LatLng(currentLatitude!, currentLongitude!),
              userLogged.email);

              
          // setState(() {
          //   _isAddingMarkers = !_isAddingMarkers;
          // });
        },
        backgroundColor: color4,
        foregroundColor: color1,
        child: Icon(_isAddingMarkers ? Icons.cancel : Icons.add_location),
      ),
    );
  }
}
