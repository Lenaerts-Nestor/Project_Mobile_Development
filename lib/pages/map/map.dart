import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

//error => naar hier [https://docs.fleaflet.dev/usage/basics ]
//toekomst => https://pub.dev/packages/material_floating_search_bar,
class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

//nog te doen:
//1- markers verwijderen.
//2- markers toevoegen [knop links beneden doen ?] \figma updaten?
//3- markers informatie bewaren.
class _MapPageState extends State<MapPage> {
  bool _isAddingMarkers = false;
  List<Marker> _markers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        //begin locatie - vragen aan meneer als het het vaste plaats gaat zijn of user location
        //als optie 2 => uitvinden hoe je dat met andriod device doet. te veel errors.
        options: MapOptions(
          center: LatLng(51.2172, 4.4212),
          zoom: 16,
          onTap: _isAddingMarkers
              ? (tapPosition, latlng) => _createMarker(latlng)
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
      //die knopje rechts beneden. niet aanraken!
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

  //methode om markers te maken.
  void _createMarker(LatLng latlng) {
    setState(() {
      _markers.add(
        Marker(
          width: 60.0,
          height: 60.0,
          point: latlng,
          builder: (ctx) => GestureDetector(
            onTap: () {
              // toon de methode.
              _showPopup(context, latlng);
              //onderzoeken hoe ik informatie bewaar van de marker.
              //classe mischien maken van markers of collection op firebase
            },
            child: Container(
              child: Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ),
        ),
      );
      _isAddingMarkers = false;
    });
  }
}

//info van databse hier zetten.
void _showPopup(BuildContext context, LatLng latLng) {
  showModalBottomSheet(
    context: context,
    //voor een of andere reden laat het true [isScrollcontrolled], anders komt die pop up maar tot 40%. onderzoek waarom of zo laten.
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
                  //momenteel dit text, later naam van iets ? locatie straat of ????
                  const Text('title mischien heir'),
                  //meer centreren? center widget werk niet. onderzoeken!.
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    iconSize: 30,
                  ),
                ],
              ),
              //vind de lijn mooi.
              const Divider(
                color: Colors.black,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              //voor het moment dit.
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
