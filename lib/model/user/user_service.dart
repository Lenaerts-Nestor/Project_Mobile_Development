//hier gaan we widgets zetten die ongeveer overal moeten staan.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkflow/model/user/user_account.dart';

import '../vehicle.dart';

//verschil tussen stream en future in kort =>
//De ene readUser() geeft een UserAccount of null terug, afhankelijk van de situatie.
//De andere versie geeft altijd een UserAccount terug en kan geen null teruggeven

//deze data word upgedate op real live, dus al we een vervoer/vehicle toevoegen, zal de pagina automatisch bijwereken wanner er nieuwe gegevens worden toegevoegd aan de database.
Stream<UserAccount> readUserByLive(String email) {
  final docUser = FirebaseFirestore.instance.collection('users').doc(email);
  return docUser.snapshots().map((snapshot) {
    if (snapshot.exists) {
      return UserAccount.fromJson(snapshot.data()!);
    } else {
      return UserAccount(
        id: '',
        familyname: '',
        name: '',
        email: '',
        password: '',
        vehicles: [],
        username: '',
      );
    }
  });
}

//met een future zullen de data niet in real life upgedate worden.
//voorbeeld profielPage.
Future<UserAccount?> readUserOnce(String userEmail) async {
  final docUser = FirebaseFirestore.instance.collection('users').doc(userEmail);
  final snapshot = await docUser.get();
  if (snapshot.exists) {
    return UserAccount.fromJson(snapshot.data()!);
  }
  return null;
}

//de update =>
//logica uitvinden en zien als alle andere pagina's de zelfde manier updaten, veronderstel van niet.


Future<void> toggleVehicleAvailability(String userId, Vehicle vehicle) async {
  final docUser = FirebaseFirestore.instance.collection('users').doc(userId);
  final updatedAvailability = List<Map<String, dynamic>>.from((await docUser.get())
      .get('vervoeren')
      .map((v) => Map<String, dynamic>.from(v)));
  final index = updatedAvailability.indexWhere((v) => v['id'] == vehicle.id);
  if (index >= 0) {
    updatedAvailability[index]['beschikbaar'] = !updatedAvailability[index]['beschikbaar'];
    await docUser.update({'vervoeren': updatedAvailability});
  }
}


//de delete =>
// zelfde situatie zoals bij updaten ??
