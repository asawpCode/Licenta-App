import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/features/meditation/meditation.dart';
import 'package:untitled/screens/main/main_page.dart';

class MeditationFeedbackPage extends StatefulWidget {
  final String meditationName;

  const MeditationFeedbackPage({super.key, required this.meditationName});

  @override
  _MeditationFeedbackPageState createState() => _MeditationFeedbackPageState();
}

class _MeditationFeedbackPageState extends State<MeditationFeedbackPage> {
  int _selectedEmoji = -1;
  final List<IconData> _emojis = [
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied
  ];

  final TextEditingController _messageController = TextEditingController();

  void _navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const MainPage(
                userName: '',
              )),
    );
  }

  void _navigateToMeditationPage() async {
    await _submitFeedback();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MeditationPage()),
    );
  }

  Future<void> _submitFeedback() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userData = await userRef.get();

      if (userData.exists) {
        List<Map<String, dynamic>> meditationHistory = userData
                .data()?['meditation_history']
                ?.cast<Map<String, dynamic>>() ??
            [];

        String feedback = '';
        switch (_selectedEmoji) {
          case 0:
            feedback = '😠';
            break;
          case 1:
            feedback = '😐';
            break;
          case 2:
            feedback = '😊';
            break;
        }

        if (feedback.isNotEmpty) {
          meditationHistory.last['feedback'] = feedback;
          meditationHistory.last['message'] = _messageController.text;
          meditationHistory.last['meditation_name'] = widget.meditationName;

          await userRef.update({
            'meditation_history': meditationHistory,
          });

          _navigateToHomePage();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('Jurnal'),
        backgroundColor: const Color(0xFF2196F3),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 30),
              const Text(
                'Cum te ai simțit dupa meditație?',
                style: TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                '',
                style: TextStyle(color: Color(0xFF757575), fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(3, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEmoji = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _selectedEmoji == index
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Icon(
                        _emojis[index],
                        color: _selectedEmoji == index
                            ? const Color(0xFFFFEB3B)
                            : const Color(0xFF0D47A1),
                        size: 52,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Lasă un mesaj în jurnalul tău',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                maxLength: 200,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text('Trimite Feedback'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF1976D2),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 10.0,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToMeditationPage,
                child: const Text('Meditează din nou'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF4CAF50),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 10.0,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
