import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

void showSnackBarWithText(
    BuildContext context, String text, Duration duration) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: duration,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

bool isEmailValid(String enteredEmail) {
  String regexPatterForEmail =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
  return isMatchingWithRegex(enteredEmail, regexPatterForEmail);
}

bool isMatchingWithRegex(String value, String regexString) {
  return RegExp(regexString.trim()).hasMatch(value);
}

DateTime convertTimestamptoDatetime(Timestamp timestamp) {
  return timestamp.toDate();
}

Timestamp? convertDateTimetoTomestamp(DateTime? dateTime) {
  return dateTime != null ? Timestamp.fromDate(dateTime) : null;
}

Timestamp convertStringToTimestamp(String dateTimeString) {
  final dateTime = DateTime.parse(dateTimeString);
  return Timestamp.fromDate(dateTime);
}

String extractTimeFromDateTime(DateTime datetime) {
  return DateFormat("HH:mm").format(datetime);
}

Future<XFile?> pickImageUsingImagePicker({bool isCamera = true}) async {
  XFile? selectedImage;
  if (isCamera) {
    selectedImage = await ImagePicker().pickImage(source: ImageSource.camera);
  } else {
    selectedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
  }
  return selectedImage;
}

String generateHash(String s1, String s2) {
  String sortedString = (<String>[s1, s2]..sort()).join();
  var bytes = utf8.encode(sortedString);
  String generatedHash = md5.convert(bytes).toString();
  print("Generating hash: $s1, $s2, $generatedHash");
  return generatedHash;
}
