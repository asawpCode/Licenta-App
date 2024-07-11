import 'package:flutter/material.dart';
import 'package:untitled/screens/login_register/login_page.dart';
import 'package:untitled/screens/login_register/register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key, Key? key1});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: togglePages, togglePages: togglePages);
    } else {
      return RegisterPage(onTap: togglePages, togglePages: togglePages);
    }
  }
}
