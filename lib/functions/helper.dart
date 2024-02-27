import 'package:flutter/material.dart';

void showSnackBarWithText(
    BuildContext context, String text, Duration duration) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: duration,
    ),
  );
}

bool isEmailValid(String enteredEmail) {
  String regexPatterForEmail =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
  return RegExp(regexPatterForEmail.trim()).hasMatch(enteredEmail);
}
