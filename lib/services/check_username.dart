import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsernameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isUsernameTaken(String username) async {
    final result = await _firestore
        .collection('users')
        .where('name', isEqualTo: username)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<bool> hasUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      return userData.exists && userData['name'] != null;
    }
    return false;
  }

  Future<void> saveUsername(String username) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = _firestore.collection('users').doc(user.uid);
      await userDoc.set(
          {'email': user.email, 'name': username}, SetOptions(merge: true));
    }
  }

  Future<bool> checkAndSaveUsername(String username) async {
    if (await isUsernameTaken(username)) {
      return false;
    }
    await saveUsername(username);
    return true;
  }
}
