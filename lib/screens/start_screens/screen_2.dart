import 'package:flutter/material.dart';
import 'package:untitled/screens/login_register/login_or_register_page.dart';

class StartScreen2 extends StatefulWidget {
  const StartScreen2({super.key});

  @override
  _StartScreen2State createState() => _StartScreen2State();
}

class _StartScreen2State extends State<StartScreen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            left: MediaQuery.of(context).size.width * 0.4,
            child: Image.asset(
              'android/assets/images/start_screen/med_1.png',
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const Text(
                      'Meditația și Somnul',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32.0),
                    const Text(
                      'Somnul este esențial pentru recuperarea fizică și mentală, consolidarea memoriei și menținerea unui sistem imunitar puternic. \n\nMeditația ajută la reducerea stresului și anxietății, îmbunătățind concentrarea și bunăstarea emoțională. Împreună, somnul și meditația promovează sănătatea generală și echilibrul psihic .',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color.fromARGB(179, 48, 47, 47),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 300.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const LoginOrRegisterPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50.0,
                          vertical: 15.0,
                        ),
                      ),
                      child: const Text(
                        'Începe',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
