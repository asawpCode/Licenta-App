import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untitled/components/textfields.dart';
import 'package:untitled/services/user_data.dart';

class MeditationHistoryPage extends StatefulWidget {
  const MeditationHistoryPage({super.key});

  @override
  _MeditationHistoryPageState createState() => _MeditationHistoryPageState();
}

class _MeditationHistoryPageState extends State<MeditationHistoryPage> {
  List<Map<String, dynamic>> _meditationHistory = [];
  final UserStatsService _userStatsService = UserStatsService();

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('ro', null);
    _loadMeditationHistory();
  }

  Future<void> _loadMeditationHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData.containsKey('meditation_history')) {
          _meditationHistory = List<Map<String, dynamic>>.from(
              userData['meditation_history'] ?? []);
        }
      }
    }
    setState(() {});
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEEE, dd.MM.yyyy', 'ro');
    return formatter.format(date);
  }

  String _formatTime(DateTime date) {
    final formatter = DateFormat('HH:mm:ss');
    return formatter.format(date);
  }

  Future<void> _addCustomMeditation() async {
    DateTime selectedDate = DateTime.now();
    int selectedDuration = 1;
    TimeOfDay selectedTime = TimeOfDay.now();
    int selectedEmoji = -1;
    TextEditingController messageController = TextEditingController();

    final List<IconData> emojis = [
      Icons.sentiment_dissatisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_satisfied,
    ];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Adaugă Meditație Personalizată',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                          'Data: ${DateFormat('dd.MM.yyyy').format(selectedDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          if (date.isAfter(DateTime.now())) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Eroare'),
                                  content:
                                      const Text('Data nu poate fi in viitor!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                        }
                      },
                    ),
                    ListTile(
                      title: Text('Durata: $selectedDuration minute'),
                      trailing: const Icon(Icons.timer),
                      onTap: () async {
                        final duration = await showDialog<int>(
                          context: context,
                          builder: (context) {
                            return NumberPickerDialog(
                              initialValue: selectedDuration,
                              minValue: 1,
                              maxValue: 120,
                            );
                          },
                        );
                        if (duration != null) {
                          setState(() {
                            selectedDuration = duration;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text(
                          'Ora terminării: ${selectedTime.format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          final selectedDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            time.hour,
                            time.minute,
                          );
                          if (selectedDateTime.isAfter(DateTime.now())) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Eroare'),
                                  content:
                                      const Text('Ora nu poate fi in viitor!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            setState(() {
                              selectedTime = time;
                            });
                          }
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List<Widget>.generate(3, (index) {
                          return IconButton(
                            icon: Icon(
                              emojis[index],
                              color: selectedEmoji == index
                                  ? Colors.blue
                                  : Colors.grey,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                selectedEmoji = index;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                    CustomTextField(
                      controller: messageController,
                      hintText: "Mesaj",
                      obscureText: false,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedEmoji != -1) {
                      _saveCustomMeditation(
                        selectedDate,
                        selectedDuration,
                        selectedTime,
                        selectedEmoji,
                        messageController.text,
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Alege un emoji pentru feedback!')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    setState(() {});
  }

  Future<void> _saveCustomMeditation(DateTime date, int duration,
      TimeOfDay time, int emojiIndex, String message,
      {String meditationName = "Nespecificat"}) async {
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
        switch (emojiIndex) {
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

        DateTime finishTime =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);

        meditationHistory.add({
          'date': Timestamp.fromDate(date),
          'duration': duration,
          'finish_time': Timestamp.fromDate(finishTime),
          'feedback': feedback,
          'message': message,
          'meditation_name': meditationName,
        });

        await userRef.update({
          'meditation_history': meditationHistory,
        });

        _userStatsService.updateMeditationStats(duration, meditationName);

        _loadMeditationHistory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text(
          'Istoric Meditație',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
            shadows: [],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: _meditationHistory.isEmpty
          ? Center(
              child: Text(
                'Nu a fost găsit niciun istoric de meditație.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _meditationHistory.length,
                itemBuilder: (context, index) {
                  final historyItem = _meditationHistory[index];
                  final date = historyItem['date'].toDate();
                  final duration = historyItem['duration'];
                  final feedback = historyItem['feedback'];
                  final message = historyItem['message'];
                  final meditationName = historyItem['meditation_name'];
                  final finishTime =
                      _formatTime(date.add(Duration(minutes: duration)));

                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            'Detalii Meditație',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          content: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFFF3E5F5),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.calendar_today),
                                  title: Text(
                                    'Data: ${_formatDate(date)}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.access_time),
                                  title: Text(
                                    'Durată: $duration minute',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.timelapse),
                                  title: Text(
                                    'Ora terminării: $finishTime',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.feedback),
                                  title: Text(
                                    'Feedback: ${feedback ?? 'Niciun feedback furnizat'}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (message != null && message.isNotEmpty)
                                  ListTile(
                                    leading: const Icon(Icons.message),
                                    title: Text(
                                      'Mesaj: $message',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                if (meditationName != null &&
                                    meditationName.isNotEmpty)
                                  ListTile(
                                    leading: const Icon(Icons.title),
                                    title: Text(
                                      'Meditație: $meditationName',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  radius: 24,
                                  child: Text(
                                    '${date.day}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDate(date),
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF0D47A1),
                                        ),
                                      ),
                                      Text(
                                        'Durată: $duration minute',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ora terminării: $finishTime',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Feedback: ${feedback ?? 'Niciun feedback furnizat'}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (meditationName != null &&
                                meditationName.isNotEmpty)
                              Text(
                                'Meditație: $meditationName',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            if (message != null && message.isNotEmpty)
                              Text(
                                'Mesaj: $message',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomMeditation,
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NumberPickerDialog extends StatefulWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;

  const NumberPickerDialog({
    super.key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
  });

  @override
  _NumberPickerDialogState createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<NumberPickerDialog> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selectează durata'),
      content: Container(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Minute: $_currentValue',
              style: const TextStyle(fontSize: 24),
            ),
            Slider(
              value: _currentValue.toDouble(),
              min: widget.minValue.toDouble(),
              max: widget.maxValue.toDouble(),
              divisions: widget.maxValue - widget.minValue,
              label: _currentValue.toString(),
              onChanged: (value) {
                setState(() {
                  _currentValue = value.toInt();
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Înapoi'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_currentValue);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
