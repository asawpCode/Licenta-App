import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStatsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getMeditationTime() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userData = await userRef.get();

      if (userData.exists) {
        return userData.data()?['total_meditation_time'] ?? 0;
      }
    }
    return 0;
  }

  Future<int> getTotalPoints() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userData = await userRef.get();

      if (userData.exists) {
        return userData.data()?['points'] ?? 0;
      }
    }
    return 0;
  }

  Future<int> getMeditationStreak() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userData = await userRef.get();

      if (userData.exists) {
        return userData.data()?['meditation_streak'] ?? 0;
      }
    }
    return 0;
  }

  Future<void> updateMeditationStats(int duration, String trackName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userData = await userRef.get();

      if (userData.exists) {
        int totalMeditationTime =
            (userData.data()?['total_meditation_time'] ?? 0) as int;
        totalMeditationTime += duration;

        List<Map<String, dynamic>> meditationHistory =
            List<Map<String, dynamic>>.from(
                userData.data()?['meditation_history'] ?? []);

        meditationHistory.add({
          'date': Timestamp.now(),
          'duration': duration,
          'meditation_name': trackName,
        });

        meditationHistory.sort((a, b) =>
            (a['date'] as Timestamp).compareTo(b['date'] as Timestamp));

        int streak = _calculateStreak(meditationHistory);

        int totalPoints = _calculateTotalPoints(totalMeditationTime);

        await userRef.update({
          'total_meditation_time': totalMeditationTime,
          'meditation_history': meditationHistory,
          'points': totalPoints,
          'level': _getLevel(totalPoints),
          'meditation_streak': streak,
        });
      } else {
        await userRef.set({
          'total_meditation_time': duration,
          'meditation_history': [
            {
              'date': Timestamp.now(),
              'duration': duration,
              'meditation_name': trackName,
            }
          ],
          'points': duration ~/ 5,
          'meditation_streak': 1,
        });
      }
    }
  }

  Future<void> updatePoints(int newTotalPoints) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      await userRef.update({'points': newTotalPoints});
    }
  }

  Future<String?> getUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userData = await userRef.get();

      if (userData.exists) {
        return userData.data()?['name'] as String?;
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getMeditationHistory() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userData = await userRef.get();

      if (userData.exists) {
        return List<Map<String, dynamic>>.from(
            userData.data()?['meditation_history'] ?? []);
      }
    }
    return [];
  }

  Future<String> getRandomQuote() async {
    try {
      final quoteDoc =
          _firestore.collection('quotes').doc('ki1yN8Td0EHqioEqQuVb');
      final docSnapshot = await quoteDoc.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        Map<String, dynamic> quotes = docSnapshot.data()!;
        int quoteCount = quotes.length;
        int chosenQuoteIndex = Random().nextInt(quoteCount);
        String quoteKey = 'citat_${chosenQuoteIndex + 1}';
        return quotes[quoteKey] ?? 'Nu a fost găsit un citat.';
      } else {
        return 'Citatul nu există sau e gol.';
      }
    } catch (e) {
      return 'Nu s-a putut incarca citatul: $e';
    }
  }

  Future<void> validateAndUpdateStreak() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userData = await userRef.get();

      if (userData.exists) {
        List<Map<String, dynamic>> meditationHistory =
            List<Map<String, dynamic>>.from(
                userData.data()?['meditation_history'] ?? []);

        if (meditationHistory.isEmpty) {
          await userRef.update({'meditation_streak': 0});
          return;
        }

        meditationHistory.sort((a, b) =>
            (a['date'] as Timestamp).compareTo(b['date'] as Timestamp));

        int streak = _calculateStreak(meditationHistory);
        await userRef.update({'meditation_streak': streak});
      }
    }
  }

  int _calculateStreak(List<Map<String, dynamic>> meditationHistory) {
    if (meditationHistory.isEmpty) return 0;

    int streak = 1;
    DateTime? lastDate;
    for (var entry in meditationHistory) {
      DateTime currentDate = (entry['date'] as Timestamp).toDate();
      DateTime normalizedCurrentDate =
          DateTime(currentDate.year, currentDate.month, currentDate.day);

      if (lastDate != null) {
        DateTime normalizedLastDate =
            DateTime(lastDate.year, lastDate.month, lastDate.day);
        int difference =
            normalizedCurrentDate.difference(normalizedLastDate).inDays;

        if (difference == 1) {
          streak++;
        } else if (difference > 1) {
          streak = 1;
        }
      }
      lastDate = normalizedCurrentDate;
    }

    return streak;
  }

  int _calculateTotalPoints(int totalMeditationTime) {
    return totalMeditationTime ~/ 5;
  }

  String _getLevel(int points) {
    if (points <= 20) {
      return 'Începător';
    } else if (points <= 81) {
      return 'Cunoscător';
    } else if (points <= 160) {
      return 'Avansat';
    } else {
      return 'PRO';
    }
  }
}
