import 'package:flutter/material.dart';

class StartScreen1 extends StatefulWidget {
  const StartScreen1({super.key});

  @override
  _StartScreen1State createState() => _StartScreen1State();
}

class _StartScreen1State extends State<StartScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: MediaQuery.of(context).size.width * 0.3,
            child: Image.asset(
              'android/assets/images/start_screen/sleep_1.png',
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image,
                  size: 150,
                  color: Colors.red,
                );
              },
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Text(
                      'Bine ai venit la CALMYO..',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.0),
                    Text(
                      'Spatiul tău personal pentru a avea parte de un stil de viata sănătos.',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color.fromARGB(179, 0, 0, 0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 340.0),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
