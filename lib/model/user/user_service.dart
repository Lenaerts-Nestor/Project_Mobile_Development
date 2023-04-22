//hier gaan we widgets zetten die ongeveer overal moeten staan.

// In a new file called user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkflow/model/user/user_account.dart';

Future<UserAccount?> readUser(String userEmail) async {
  final docUser = FirebaseFirestore.instance.collection('users').doc(userEmail);
  final snapshot = await docUser.get();
  if (snapshot.exists) {
    return UserAccount.fromJson(snapshot.data()!);
  }
  return null;
}

//de update => 
//logica uitvinden en zien als alle andere pagina's de zelfde manier updaten, veronderstel van niet.
//de delete => 
// zelfde situatie zoals bij updaten ??