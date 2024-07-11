import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled/services/auth_page.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double scaleFactor = 0.4;

    return Scaffold(
      body: SafeArea(
        child: AnimatedSplashScreen(
          splash: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Transform.scale(
                scale: scaleFactor,
                child: Lottie.asset(
                  'android/assets/videos/splash.json',
                ),
              ),
            ),
          ),
          nextScreen: const AuthPage(),
          splashTransition: SplashTransition.fadeTransition,
          pageTransitionType: PageTransitionType.leftToRight,
          duration: 3000,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }
}
