import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/start_screens/start_screen.dart';
import 'package:untitled/screens/login_register/username.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, Key? key1});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return const UsernamePage();
          } else {
            return const StartScreen();
          }
        },
      ),
    );
  }
}
