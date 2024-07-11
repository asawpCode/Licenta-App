import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled/components/navigation.dart';
import 'package:untitled/features/meditation/meditation_player.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  _MeditationPageState createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  List<Map<String, dynamic>> recommendedMeditations = [];
  List<Map<String, dynamic>> breathingExercises = [];
  List<Map<String, dynamic>> meditationItems = [];

  @override
  void initState() {
    super.initState();
    _fetchRecommendedMeditations();
    _fetchMeditationData();
    _fetchBreathingExercises();
  }

  Future<void> _fetchRecommendedMeditations() async {
    try {
      final List<Map<String, dynamic>> fetchedMeditations = [];
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('meditationMetadata')
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String audioName = data['audioName'];
        final ref = FirebaseStorage.instance
            .ref()
            .child('audio/meditatie/ghidata/$audioName');

        try {
          await ref.getDownloadURL();
          fetchedMeditations.add({
            'title': data['title'],
            'duration': data['duration'],
            'audioName': data['audioName'],
          });
        } catch (e) {}
      }

      setState(() {
        recommendedMeditations = fetchedMeditations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la obținerea exercițiilor: $e')),
      );
    }
  }

  Future<void> _fetchMeditationData() async {
    try {
      final List<Map<String, dynamic>> fetchedMeditations = [];
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('relaxMeditationMetadata')
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        fetchedMeditations.add(data);
      }

      setState(() {
        meditationItems = fetchedMeditations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la preluarea meditației: $e')),
      );
    }
  }

  Future<void> _fetchBreathingExercises() async {
    try {
      final List<Map<String, dynamic>> fetchedBreathingExercises = [];
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('meditationMetadata')
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String audioName = data['audioName'];
        final ref = FirebaseStorage.instance
            .ref()
            .child('audio/meditatie/exercitii/$audioName');

        try {
          await ref.getDownloadURL();
          fetchedBreathingExercises.add({
            'title': data['title'],
            'duration': data['duration'],
            'audioName': data['audioName'],
          });
        } catch (e) {}
      }

      setState(() {
        breathingExercises = fetchedBreathingExercises;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la preluarea meditației: $e')),
      );
    }
  }

  void _showMeditationModal(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
      ),
      builder: (BuildContext context) {
        int _selectedDuration = 5;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(35),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Lottie.asset(
                      item['assetPath'],
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
                        item['details'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Text(
                      "Selectează durata meditației:",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    Slider(
                      value: _selectedDuration.toDouble(),
                      min: 1,
                      max: 120,
                      divisions: 24,
                      label: '$_selectedDuration MIN',
                      onChanged: (double value) {
                        setModalState(() {
                          _selectedDuration = value.toInt();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PlayerScreen(
                              trackName: item['title'],
                              trackType: 'Meditatie',
                              trackUrl:
                                  'audio/meditatie/relaxare/${item['audioName']}',
                              duration: _selectedDuration,
                              isInteractive: false,
                            ),
                          ),
                        );
                      },
                      child: const Text('Începe meditația'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        foregroundColor: const Color.fromARGB(255, 0, 99, 248),
                        backgroundColor:
                            const Color.fromARGB(255, 149, 219, 247),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0.15 * screenHeight,
            left: 0,
            right: 0,
            child: Lottie.asset(
              'android/assets/videos/sun.json',
            ),
          ),
          Positioned(
            top: 0.05 * screenHeight,
            left: 0.05 * screenWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meditație',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Găsește-ți liniștea interioară',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 99, 99, 99),
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0.335 * screenHeight,
            left: 0,
            right: 0,
            bottom: 100.0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Sunete relaxante',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Alege un sunet și setează timpul!',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 99, 99, 99),
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: screenHeight * 0.45,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: meditationItems.length,
                        itemBuilder: (context, index) {
                          final item = meditationItems[index];
                          return Container(
                            width: screenWidth * 0.75,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: GestureDetector(
                              onTap: () => _showMeditationModal(context, item),
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: item['assetType'] == 'lottie'
                                              ? Lottie.asset(
                                                  item['assetPath'],
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.asset(
                                                  item['assetPath'],
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
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      item['description'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 80),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Meditații Ghidate',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Alege din meditațiile recomandate pentru tine',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 99, 99, 99),
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      height: screenHeight * 0.25,
                      child: recommendedMeditations.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: recommendedMeditations.length,
                              itemBuilder: (context, index) {
                                final item = recommendedMeditations[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => PlayerScreen(
                                          trackName: item['title'],
                                          trackType: 'Meditație',
                                          trackUrl:
                                              'audio/meditatie/ghidata/${item['audioName']}',
                                          duration: item['duration'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: screenWidth * 0.35,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Card(
                                      color: const Color.fromARGB(
                                          255, 246, 246, 247),
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Lottie.asset(
                                                'android/assets/videos/load.json',
                                                fit: BoxFit.cover,
                                              ),
                                              Text(
                                                item['title'],
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 47, 54, 56),
                                                ),
                                              ),
                                              Text(
                                                '~${item['duration']} min',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 32, 34, 158),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 80),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Exerciții Respirație',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Alege unul dintre exercițiile de respirație recomandate',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 99, 99, 99),
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      height: screenHeight * 0.25,
                      child: breathingExercises.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: breathingExercises.length,
                              itemBuilder: (context, index) {
                                final item = breathingExercises[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => PlayerScreen(
                                          trackName: item['title'],
                                          trackType: 'Meditație',
                                          trackUrl:
                                              'audio/meditatie/exercitii/${item['audioName']}',
                                          duration: item['duration'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: screenWidth * 0.3,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 30.0),
                                    child: Card(
                                      color: const Color.fromARGB(
                                          255, 246, 246, 247),
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Lottie.asset(
                                                'android/assets/videos/breathe.json',
                                                fit: BoxFit.cover,
                                              ),
                                              Text(
                                                item['title'],
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 47, 54, 56),
                                                ),
                                              ),
                                              Text(
                                                '~${item['duration']} min',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 255, 105, 5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavigationBar(
              onItemSelected: (int value) {},
              currentIndex: 1,
            ),
          ),
        ],
      ),
    );
  }
}
