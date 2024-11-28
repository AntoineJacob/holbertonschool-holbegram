import 'package:flutter/material.dart';


// Classe représentant un champ de texte
class TextFieldInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isPassword;
  final String hintText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  // Constructeur pour initialiser les propriétés
  const TextFieldInput({
    super.key,
    required this.controller,
    this.isPassword = false,
    required this.hintText,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  // Méthode pour construire le widget
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      controller: controller,
      cursorColor: const Color.fromARGB(218, 226, 37, 24),
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        filled: true,
        fillColor: const Color.fromRGBO(240, 240, 240, 1.0),
        contentPadding: const EdgeInsets.all(8),
        suffixIcon: suffixIcon,
      ),
      textInputAction: TextInputAction.next,
      obscureText: isPassword,
    );
  }
}