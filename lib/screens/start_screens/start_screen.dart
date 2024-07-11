import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:untitled/screens/start_screens/screen_1.dart';
import 'package:untitled/screens/start_screens/screen_2.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: const [
              StartScreen1(),
              StartScreen2(),
            ],
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: SmoothPageIndicator(
                      controller: _controller,
                      count: 2,
                      effect: const JumpingDotEffect(
                        activeDotColor: Color.fromARGB(255, 14, 144, 219),
                        dotColor: Color.fromARGB(255, 18, 207, 91),
                        dotHeight: 12,
                        dotWidth: 12,
                        spacing: 14,
                      ))))
        ],
      ),
    );
  }
}
