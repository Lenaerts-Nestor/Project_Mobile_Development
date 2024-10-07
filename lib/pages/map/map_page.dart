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
import 'package:flutter/foundation.dart' show kIsWeb;
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
  final bool _isAddingMarkers = false;
  List<Marker> _markers = [];
  late Timer _timer;
  double? currentLatitude;
  double? currentLongitude;

  @override
  void initState() {
    super.initState();

    _determinePosition();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      updateMarkerState();
      _updateMarkers();
    });
  }

  //zet de markers op de map van de database
  void _updateMarkers() {
    getMarkersFromDatabase(context, (List<Marker> markers) {
      setState(() {
        _markers = markers;
      });
    });
  }



void _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    return;
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return;
    }
  }

  if (kIsWeb) {
    // For web, use getCurrentPosition instead of getLastKnownPosition
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
      });
    } catch (e) {
      print('Error getting current position: $e');
    }
  } else {
    // For mobile platforms, use getLastKnownPosition as before
    Position? position = await Geolocator.getLastKnownPosition();
    if (position != null) {
      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
      });
    }
  }
}

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userLogged = Provider.of<UserLogged>(context);
    LatLng? userLocation;

    if (currentLatitude != null && currentLongitude != null) {
      userLocation = LatLng(currentLatitude!, currentLongitude!);
    }
    return Scaffold(
      body: userLocation != null
          ? FlutterMap(
              options: MapOptions(
                initialCenter: userLocation == null
                    ? LatLng(51.2172, 4.4212)
                    : LatLng(currentLatitude!, currentLongitude!),
                minZoom: 16,
                maxZoom: 30,
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    LatLng(51.18, 4.33),
                    LatLng(51.25, 4.46),
                  ),
                ),
                onTap: _isAddingMarkers
                    ? (tapPosition, point) {
                        showPopupPark(context, point, userLogged.email);
                      }
                    : null,
              ),
              children: [
                TileLayer(
                  urlTemplate: mapboxUrl,
                  additionalOptions: {'accessToken': mapboxAccessToken},
                ),
                MarkerLayer(markers: _markers),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          bool markerExists =
              checkMarker(_markers, currentLatitude!, currentLongitude!);

          if (!markerExists) {
            if (userLocation != null) {
              showPopupPark(context, userLocation, userLogged.email);
            } else {
              //geen locatie gevonden
              showPopupPark(context, LatLng(51.2172, 4.4212), userLogged.email);
            }
          } else {
            //marker bestaat al op deze locatie
          }

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

bool checkMarker(List<Marker> markers, double latitude, double longitude) {
  for (var marker in markers) {
    if (marker.point.latitude == latitude &&
        marker.point.longitude == longitude) {
      return true;
    }
  }
  return false;
}