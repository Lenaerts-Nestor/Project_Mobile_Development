//naam van de straat krijgen =>
import 'package:osm_nominatim/osm_nominatim.dart';

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
