import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled/components/my_button.dart';
import 'package:untitled/components/textfields.dart';
import 'package:untitled/screens/main/main_page.dart';
import 'package:untitled/services/check_username.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  _UsernamePageState createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  String? _errorMessage;
  final UsernameService _usernameService = UsernameService();
  bool _navigatedToMainPage = false;

  @override
  void initState() {
    super.initState();
    _checkUsername();
  }

  Future<void> _checkUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!mounted) return;

        final username = userDoc.data()?['name'] as String?;
        print('Numele de utilizator din Firestore: $username');

        if (username != null && username.isNotEmpty && !_navigatedToMainPage) {
          _navigateToMainPage();
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Eroare la preluarea datelor: $e');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Nu exista utilizator logat.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUsername(String username) async {
    setState(() {
      _errorMessage = null;
    });
    try {
      if (await _usernameService.checkAndSaveUsername(username)) {
        _navigateToMainPage();
      } else {
        setState(() {
          _errorMessage = 'Numele de utilizator este deja folosit.';
        });
      }
    } catch (e) {
      print('Eroare la salvare: $e');
      setState(() {
        _errorMessage =
            'Eroare la salvarea numelui de utilizator. Te rog mai incearcă.';
      });
    }
  }

  void _navigateToMainPage() {
    setState(() {
      _navigatedToMainPage = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => MainPage(userName: _nameController.text)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Lottie.asset(
            'android/assets/videos/bg1.json',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 250),
                  const Text(
                    'Alege un nume de utilizator',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(221, 255, 255, 254),
                      letterSpacing: 0.5,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: _nameController,
                    hintText: "Numele de utilizator",
                    style: const TextStyle(),
                    obscureText: false,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  MyButton(
                    onTap: () async {
                      if (_nameController.text.isNotEmpty) {
                        await _saveUsername(_nameController.text);
                      }
                    },
                    text: 'Salvare',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
