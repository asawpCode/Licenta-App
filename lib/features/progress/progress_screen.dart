import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:untitled/features/progress/progress.dart';
import 'package:untitled/services/user_data.dart';

class ProgressionScreen extends StatefulWidget {
  const ProgressionScreen({super.key});

  @override
  _ProgressionScreenState createState() => _ProgressionScreenState();
}

class _ProgressionScreenState extends State<ProgressionScreen> {
  int totalPoints = 0;
  int currentStreak = 0;
  String userLevel = 'Incepător';
  List<Map<String, dynamic>> pointsHistory = [];

  final UserStatsService _userStatsService = UserStatsService();

  @override
  void initState() {
    super.initState();
    _fetchPointsData();
  }

  Future<void> _fetchPointsData() async {
    final totalMinutes = await _userStatsService.getMeditationTime();
    final meditationProgress = MeditationProgress(totalMinutes);
    final newTotalPoints = meditationProgress.getPoints();

    await _userStatsService.updatePoints(newTotalPoints);

    final fetchedPoints = await _userStatsService.getTotalPoints();
    final fetchedHistory = await _userStatsService.getMeditationHistory();
    final fetchedStreak = await _userStatsService.getMeditationStreak();

    setState(() {
      totalPoints = fetchedPoints;
      userLevel = meditationProgress.getLevel();
      pointsHistory = fetchedHistory;
      currentStreak = fetchedStreak;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progresul tău',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
            shadows: [],
          ),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildPointsDisplay(),
          Expanded(child: _buildPointsHistory()),
        ],
      ),
    );
  }

  Widget _buildPointsDisplay() {
    double progressPercentage =
        MeditationProgress.calculateProgressPercentage(totalPoints);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 30),
          CircularPercentIndicator(
            radius: 120.0,
            lineWidth: 15.0,
            animation: true,
            percent: progressPercentage,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$totalPoints',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const Text(
                  'Puncte',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.blueAccent,
            backgroundColor: Colors.blue.shade100,
          ),
          const SizedBox(height: 20),
          Text(
            'Nivel: $userLevel',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Streak: $currentStreak',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsHistory() {
    final filteredHistory = pointsHistory
        .where((historyEntry) => (historyEntry['duration'] ?? 0) ~/ 5 > 0)
        .toList();

    return filteredHistory.isEmpty
        ? const Center(child: Text('Inca nu ai niciun punct!'))
        : ListView.builder(
            itemCount: filteredHistory.length,
            itemBuilder: (context, index) {
              final historyEntry = filteredHistory[index];
              final pointsEarned = (historyEntry['duration'] ?? 0) ~/ 5;
              final date = (historyEntry['date'] as Timestamp).toDate();
              final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
              return ListTile(
                title: Text(
                  'Felicitari! Ai primit niste puncte: $pointsEarned',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '$formattedDate - ${historyEntry['meditation_name']}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              );
            },
          );
  }
}
