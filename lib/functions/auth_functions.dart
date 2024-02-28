import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:chat_app/functions/helper.dart';

class AuthFunctions {
  AuthFunctions(this.context);
  final BuildContext context;
  late UserCredential userCredential;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> authenticateUser(
      bool isLogin, String enteredEmail, String enteredPassword) async {
    try {
      if (!isLogin) {
        userCredential = await auth.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
      } else {
        userCredential = await auth.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
      }
    } on FirebaseAuthException catch (err) {
      if (context.mounted) {
        showSnackBarWithText(
          context,
          err.message ?? 'Authentication failed.',
          const Duration(seconds: 4),
        );
        rethrow;
      }
    }
  }

  Future<String> putFiletoFirebaseStorage(XFile selectedImage) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_Image')
          .child(userCredential.user!.uid);
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': selectedImage.path},
      );
      UploadTask uploadTask;
      if (kIsWeb) {
        final dataa = await selectedImage.readAsBytes();
        uploadTask = storageRef.putData(dataa, metadata);
      } else {
        uploadTask = storageRef.putFile(io.File(selectedImage.path), metadata);
      }
      final snapshot = await uploadTask.whenComplete(() => null);
      final String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } on Exception catch (err) {
      userCredential.user!.delete();
      if (context.mounted) {
        showSnackBarWithText(
          context,
          "Image Could Not be Uploaded. Due to error: ${err.toString()}",
          const Duration(seconds: 5),
        );
      }
      return "";
    }
  }

  Future<void> saveDataToFirestore(
      String downloadURL, String enteredEmail, String enteredUsername) async {
    try {
      final Map<String, String> data = {
        "user_name": enteredUsername,
        "email": enteredEmail,
        "uid": userCredential.user!.uid,
        "user_image": downloadURL
      };
      db.collection("users").doc(userCredential.user!.uid).set(data);
    } on Exception catch (err) {
      if (context.mounted) {
        showSnackBarWithText(
          context,
          "Image Could Not be Uploaded. Due to error: ${err.toString()}",
          const Duration(seconds: 5),
        );
      }
    }
  }
}
