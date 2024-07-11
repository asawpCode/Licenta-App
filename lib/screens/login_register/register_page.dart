import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/components/my_button.dart';
import 'package:untitled/components/square.dart';
import 'package:untitled/services/auth_page.dart';
import 'package:untitled/services/auth_service.dart';
import '../../components/textfields.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  final void Function() togglePages;

  const RegisterPage({
    super.key,
    required this.onTap,
    required this.togglePages,
  });

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        );
      },
    );

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      showErrorMessage();
    } else {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthPage(),
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        print("Eroare Înregistrare: $e");
        showErrorMessage();
      }
    }
  }

  void showErrorMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[100],
          title: const Text("Eroare de autentificare"),
          content: const Text("A aparut o problemă. Te rog incearca din nou!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color.fromARGB(255, 217, 229, 233),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Image.asset(
                  'android/assets/images/1.png',
                  height: 120,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Salut! Bine ai venit!",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: emailController,
                  hintText: "Adresa Email",
                  style: const TextStyle(),
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: passwordController,
                  obscureText: true,
                  hintText: "Parola",
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  hintText: "Confirmă Parola",
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                MyButton(
                  onTap: signUserUp,
                  text: "Înregistrare",
                  onPressed: () {},
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "Continuă cu",
                          style: TextStyle(
                            color: Color.fromARGB(255, 87, 87, 87),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final user = await _authService.signInWithGoogle();
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthPage(),
                            ),
                          );
                        } else {}
                      },
                      child: const Square(
                        imagePath: 'android/assets/logo/google_logo.png',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text(
                    "Ai deja cont?",
                    style: TextStyle(
                      color: Color.fromARGB(255, 23, 25, 29),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Loghează-te acum",
                      style: TextStyle(
                        color: Color.fromARGB(255, 19, 109, 165),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
