import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled/components/navigation.dart';
import 'package:untitled/features/meditation/meditation_player.dart';
import 'package:untitled/features/sleep/constants.dart';
import 'package:untitled/features/sleep/sleep_player.dart';
import 'package:untitled/features/sleep/sound_tile.dart';
import 'package:untitled/services/audio_service.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  final AudioService _audioService = AudioService();
  List<Map<String, dynamic>> recommendedMeditations = [];

  @override
  void initState() {
    super.initState();
    _fetchRecommendedMeditations();
  }

  void _showMeditationModal(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
      ),
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        return Container(
          padding: const EdgeInsets.all(35),
          width: screenWidth * 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                item['animationPath'],
                width: 200,
                height: 200,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 20),
              Text(
                item['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  item['description'] ?? 'Nu există descriere',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(
                        trackName: item['title'],
                        trackType: 'Somn',
                        trackUrl: 'audio/somn/ghidat/${item['audioName']}',
                        duration: item['duration'],
                      ),
                    ),
                  );
                },
                child: const Text('Start Meditație'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 69, 165, 202),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchRecommendedMeditations() async {
    try {
      final List<Map<String, dynamic>> fetchedMeditations = [];
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('sleepMetadata').get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        fetchedMeditations.add({
          'title': data['title'],
          'duration': data['duration'],
          'audioName': data['audioName'],
          'animationPath': data['animationPath'],
          'description': data['description'],
          'details': data['details'],
        });
      }

      fetchedMeditations.sort((a, b) => a['duration'].compareTo(b['duration']));

      setState(() {
        recommendedMeditations = fetchedMeditations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare căutând meditațiile: $e')),
      );
    }
  }

  void _showDraggablePopUp(
      BuildContext context, List<Map<String, String>> soundFiles) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 1,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: 10,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Selectează un sunet',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Divider(color: Colors.grey),
              Expanded(
                child: ListView.builder(
                  itemCount: soundFiles.length,
                  itemBuilder: (context, index) {
                    Map<String, String> sound = soundFiles[index];
                    return SoundTile(
                      title: sound['name']!,
                      soundUrl: sound['url']!,
                      audioService: _audioService,
                      onAudioSelected:
                          (String selectedUrl, DateTime selectedTime) async {
                        Navigator.pop(context, {
                          'title': sound['name']!,
                          'url': selectedUrl,
                          'time': selectedTime
                        });
                      },
                      stopCurrentAudio: _stopCurrentAudio,
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    ).then((result) {
      if (result != null) {
        _startSleepPlayerScreen(
            context, result['title'], result['url'], result['time']);
      }
    });
  }

  Future<void> _fetchAndShowPopup(BuildContext context) async {
    List<Map<String, String>> soundFiles =
        await _audioService.fetchAudioUrlsWithNames('audio/somn');
    _showDraggablePopUp(context, soundFiles);
  }

  void _startSleepPlayerScreen(BuildContext context, String trackName,
      String soundUrl, DateTime selectedTime) {
    final now = DateTime.now();
    final wakeUpTime = DateTime(
        now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SleepPlayerScreen(
          trackName: trackName,
          trackUrl: soundUrl,
          trackType: 'Somn',
          wakeUpTime: wakeUpTime.toIso8601String(),
          duration: 0,
        ),
      ),
    );
  }

  void _stopCurrentAudio() {
    _audioService.stopAudio();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(children: [
        Lottie.asset(
          'android/assets/videos/bg2.json',
          width: double.infinity,
          height: double.infinity,
          repeat: true,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: -0.1 * screenHeight,
          left: 0,
          right: 0,
          child: Image.asset(
            'android/assets/images/sleep/2.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 0.08 * screenHeight,
          left: 0.1 * screenWidth,
          right: 0.1 * screenWidth,
          child: Image.asset(
            'android/assets/images/sleep/1.png',
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 0.12 * screenHeight,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Somn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Găseste-ți liniștea și odihna de care ai nevoie.',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 119, 117, 117),
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 0.02 * screenHeight,
                ),
                AnimatedGradientContainer(
                  height: 0.115 * screenHeight,
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: BoxShadow(
                    color: const Color.fromARGB(255, 96, 111, 160)
                        .withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Alege sunetul preferat și setează-ti alarma de trezire!',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.005,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _fetchAndShowPopup(context);
                        },
                        child: Text(
                          'START',
                          style: TextStyle(
                            fontSize: screenHeight * 0.01,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenHeight * 0.02,
                          ),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 0.03 * screenHeight,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Meditații Somn Ghidate',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Meditează împreuna cu ghiduri pentru a adormi!',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 99, 99, 99),
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            height: screenHeight * 0.45,
                            child: recommendedMeditations.isEmpty
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: recommendedMeditations.length,
                                    itemBuilder: (context, index) {
                                      final item =
                                          recommendedMeditations[index];
                                      return Container(
                                        width: screenWidth * 0.75,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: GestureDetector(
                                          onTap: () => _showMeditationModal(
                                              context, item),
                                          child: Card(
                                            color: const Color.fromARGB(
                                                255, 65, 98, 247),
                                            elevation: 5,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Center(
                                                      child: Lottie.asset(
                                                        item['animationPath'],
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  item['title'],
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  '~${item['duration']} min',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromARGB(
                                                        255, 151, 151, 151),
                                                  ),
                                                ),
                                                const SizedBox(height: 15),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 45),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: CustomBottomNavigationBar(
            onItemSelected: (int value) {},
            currentIndex: 2,
          ),
        ),
      ]),
    );
  }
}
