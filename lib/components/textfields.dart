import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final TextStyle? style;
  final double? height;
  final double? width;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.style,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      height: height,
      width: width,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(255, 241, 239, 239),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 5, 5, 5),
            ),
          ),
          hintText: hintText,
        ),
      ),
    );
  }
}
