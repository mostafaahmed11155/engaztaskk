import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final TextInputType type;
  final TextEditingController controller;
  final bool? secureText;
  final Widget? suffix;
  const CustomTextField({
    super.key,
    required this.title,
    required this.controller,
    this.secureText = false,
    this.suffix,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: secureText!,
      keyboardType: type!,
      decoration: InputDecoration(
        labelText: title,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderSide:
          const BorderSide(width: 3, color: Colors.transparent), //<-- SEE HERE
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder:  OutlineInputBorder(
          borderSide:
          BorderSide(width: 3, color: Colors.transparent), //<-- SEE HERE
      borderRadius: BorderRadius.circular(10.0),
    ),
      ),
    );
  }
}