import 'package:cloud_firestore/cloud_firestore.dart';

class UserPointsService {
  Future<int> getUserPoints(String userId) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userData = await userRef.get();

      if (userData.exists &&
          userData.data()!.containsKey('meditation_history')) {
        List meditationHistory = userData['meditation_history'];
        int totalMinutes = meditationHistory.fold<int>(0, (sum, entry) {
          return sum + (entry['duration'] as int? ?? 0);
        });
        return totalMinutes ~/ 5;
      } else {
        return 0;
      }
    } catch (e) {
      print('Eroare la preluarea punctelor: $e');
      return 0;
    }
  }
}
