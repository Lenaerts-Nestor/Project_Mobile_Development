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

//nog te doen:
//1- markers verwijderen.
//2- markers toevoegen [knop links beneden doen ?] \figma updaten?
//3- markers informatie bewaren.

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        //begin locatie - vragen aan meneer als het het vaste plaats gaat zijn of user location
        //als optie 2 => uitvinden hoe je dat met andriod device doet. te veel errors.
        center: LatLng(51.2172, 4.4212),
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
                  // toon de methode.
                  _showPopup(context);
                  //onderzoeken hoe ik informatie bewaar van de marker.
                  //classe mischien maken van markers of collection op firebase
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

//methode om de pop up the tonen.
  void _showPopup(BuildContext context) {
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
                //mischien underline ? figma updaten ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //momenteel dit text, later naam van iets ? locatie straat of ????
                    const Text('Dit is de pop-up',
                        style: TextStyle(fontSize: 24)),
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
                //sebiet dingens toevoegen hier? locatie en uren ?
              ],
            ),
          ),
        );
      },
    );
  }
}
