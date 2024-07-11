import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled/components/navigation.dart';
import 'package:untitled/features/meditation/meditation.dart';
import 'package:untitled/features/meditation/meditation_history.dart';
import 'package:untitled/features/progress/progress.dart';
import 'package:untitled/features/progress/progress_screen.dart';
import 'package:untitled/features/sleep/sleep.dart';
import 'package:untitled/services/user_data.dart';

class MainPage extends StatefulWidget {
  final String userName;
  const MainPage({super.key, required this.userName});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<String?> _userNameFuture;
  late Future<int> _totalMeditationTimeFuture;
  late Future<String> _quoteFuture;
  Timer? _timer;
  final UserStatsService _userStatsService = UserStatsService();

  @override
  void initState() {
    super.initState();
    _userNameFuture = _userStatsService.getUserName();
    _totalMeditationTimeFuture = _userStatsService.getMeditationTime();
    _quoteFuture = _userStatsService.getRandomQuote();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      setState(() {
        _quoteFuture = _userStatsService.getRandomQuote();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: AppBar(
            title: Image.asset(
              'android/assets/logo/app.png',
              width: 130,
              fit: BoxFit.contain,
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(255, 136, 176, 245),
          ),
        ),
      ),
      body: Stack(
        children: [
          Lottie.asset(
            'android/assets/videos/bg4.json',
            width: double.infinity,
            height: double.infinity,
            repeat: true,
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: FutureBuilder<String?>(
              future: _userNameFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final username = snapshot.data ?? widget.userName;
                  return _buildContent(context, username);
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavigationBar(
              onItemSelected: (int value) {},
              currentIndex: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, String username) {
    return Column(
      children: [
        const SizedBox(height: 35),
        _buildWelcomeMessage(username),
        const SizedBox(height: 30),
        FutureBuilder<int>(
          future: _totalMeditationTimeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Eroare: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final totalMeditationTime = snapshot.data!;
              return _buildStatsBox(totalMeditationTime);
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        const SizedBox(height: 10),
        _buildMainOptions(context),
        const SizedBox(height: 15),
        FutureBuilder<String>(
          future: _quoteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Eroare: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final quote = snapshot.data!;
              return _buildQuotesContainer(context, quote);
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        const SizedBox(height: 75),
      ],
    );
  }

  Widget _buildWelcomeMessage(String username) {
    return Align(
      alignment: const Alignment(-0.8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bine ai venit, $username',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Text(
            'Ce dorești să faci astăzi?',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBox(int totalMeditationTime) {
    final progress = MeditationProgress(totalMeditationTime);

    return Container(
      padding: const EdgeInsets.all(18.0),
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 136, 176, 245),
        borderRadius: BorderRadius.circular(22.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 28.0),
                  const SizedBox(width: 10.0),
                  Text(
                    'Timp total meditație: $totalMeditationTime min',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 252, 252, 252),
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              IconButton(
                icon:
                    const Icon(Icons.history, color: Colors.white, size: 28.0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MeditationHistoryPage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nivel: ${progress.getLevel()}',
                style: const TextStyle(
                  color: Color.fromARGB(255, 252, 252, 252),
                  fontSize: 18.0,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward,
                    color: Colors.white, size: 28.0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProgressionScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainOptions(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildOptionCard(
            context,
            'android/assets/images/meditation.jpeg',
            'Meditație',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MeditationPage()),
              );
            },
          ),
          _buildOptionCard(
            context,
            'android/assets/images/sleep.png',
            'Somn',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SleepPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String imagePath, String title,
      VoidCallback onPressed) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.3,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 145, 145, 143).withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: onPressed,
              icon: const Icon(
                Icons.play_circle_fill_outlined,
                size: 50,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotesContainer(BuildContext context, String quote) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) {
            setState(() {
              isHovered = true;
            });
          },
          onExit: (_) {
            setState(() {
              isHovered = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.all(25),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isHovered ? Colors.blue.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isHovered ? 1.0 : 0.8,
                  child: Text(
                    quote,
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
