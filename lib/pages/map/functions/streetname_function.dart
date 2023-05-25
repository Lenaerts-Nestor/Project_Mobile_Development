import 'package:osm_nominatim/osm_nominatim.dart';

/// Beschrijving: Haalt de straatnaam op basis van de opgegeven [Latitude] en [Longitude] door gebruik te maken van de *Nominatim-service* [dependency].

Future<String> getStreetName(double latitude, double longitude) async {
  // Create a Nominatim instance
  final searchResult = await Nominatim.reverseSearch(
      lat: latitude,
      lon: longitude,
      addressDetails: true,
      extraTags: true,
      nameDetails: true);

  return searchResult.address!['road'].toString();
}
