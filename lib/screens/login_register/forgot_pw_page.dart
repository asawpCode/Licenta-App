import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/components/textfields.dart';
import 'package:untitled/screens/login_register/login_or_register_page.dart';
import 'package:untitled/components/my_button.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  ForgotPasswordPage({super.key});

  void sendResetPasswordEmail(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text,
      );
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Resetare parolă'),
          content: Text(
            'Un email a fost trimis la adresa ${emailController.text} pentru resetarea parolei. Vă rugăm să verificați inbox-ul sau spam-ul.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginOrRegisterPage(),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eroare'),
          content: const Text(
            'A apărut o eroare la trimiterea emailului de resetare a parolei. Vă rugăm să încercați din nou mai târziu.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resetare parolă'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 25),
              CustomTextField(
                controller: emailController,
                hintText: 'Adresa de Email',
                obscureText: false,
              ),
              const SizedBox(height: 20),
              MyButton(
                onTap: () => sendResetPasswordEmail(context),
                text: 'Trimite cerere de resetare',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
