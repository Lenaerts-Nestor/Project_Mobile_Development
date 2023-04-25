// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, avoid_unnecessary_containers, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:provider/provider.dart';

String username = 'krupuks';
String tilesize = '256';
String scale = '2';
String mapboxAccessToken =
    'pk.eyJ1Ijoia3J1cHVrcyIsImEiOiJjbGd1a2Y4aDMyM2RpM2NtdDF0OWl5aXJyIn0.T-90bn65p10SjFwgfBiWyg';
String mapboxUrl =
    'https://api.mapbox.com/styles/v1/$username/clgukhlsf005g01o58vp31upm/tiles/$tilesize/{z}/{x}/{y}@${scale}x?access_token=$mapboxAccessToken';

final _firestore = FirebaseFirestore.instance;

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
    _getMarkersFromDatabase();
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
              ? (tapPosition, latlng) => _createMarker(latlng, userEmail)
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

  Future<void> _getMarkersFromDatabase() async {
    final markersSnapshot = await _firestore.collection('markers').get();

    setState(() {
      _markers = markersSnapshot.docs.map((doc) {
        LatLng latLng = LatLng(doc['latitude'], doc['longitude']);
        return _createMarkersInMap(latLng, doc['userId']);
      }).toList();
    });
  }

  void _createMarker(LatLng latlng, String userId) {
    _saveMarkerToDatabase(latlng, userId);
    setState(() {
      _markers.add(_createMarkersInMap(latlng, userId));
      _isAddingMarkers = false;
    });
  }

  Marker _createMarkersInMap(LatLng latlng, String userId) {
    final userLogged = Provider.of<UserLogged>(context, listen: false);
    final userEmail = userLogged.email.trim();
    final markerColor = userEmail == userId ? Colors.blue : Colors.black;
    return Marker(
      width: 60.0,
      height: 60.0,
      point: latlng,
      builder: (ctx) => GestureDetector(
        onTap: () {
          // Show the popup
          _showPopup(context, latlng);
        },
        child: Container(
          child: Icon(Icons.location_on, color: markerColor, size: 40),
        ),
      ),
    );
  }

  Future<void> _saveMarkerToDatabase(LatLng latlng, String userId) async {
    await _firestore.collection('markers').add({
      'latitude': latlng.latitude,
      'longitude': latlng.longitude,
      'userId': userId,
    });
  }
}

void _showPopup(BuildContext context, LatLng latLng) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('title mischien heir'),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    iconSize: 30,
                  ),
                ],
              ),
              const Divider(
                color: Colors.black,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              Text('Latitude: ${latLng.latitude}',
                  style: const TextStyle(fontSize: 24)),
              Text('longitude: ${latLng.longitude}',
                  style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),
      );
    },
  );
}
