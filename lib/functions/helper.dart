import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


void showSnackBarWithText(
    BuildContext context, String text, Duration duration) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
    ),
  );
}

bool isEmailValid(String enteredEmail) {
  String regexPatterForEmail =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
  return isMatchingWithRegex(enteredEmail, regexPatterForEmail);
}

bool isMatchingWithRegex(String value, String regexString){
  return RegExp(regexString.trim()).hasMatch(value);
}

DateTime? convertTimestamp(Timestamp? timestamp) {
  return timestamp?.toDate();
}

Timestamp? convertDateTime(DateTime? dateTime) {
  return dateTime != null ? Timestamp.fromDate(dateTime) : null;
}

  Future<XFile?> pickImageUsingImagePicker({bool isCamera = true}) async {
    XFile? selectedImage;
    if (isCamera) {
      selectedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      selectedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 200,
      );
    }
    return selectedImage;
  }
