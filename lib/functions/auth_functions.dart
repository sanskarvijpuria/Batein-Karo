import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:batein_karo/functions/APIS.dart';
import 'package:batein_karo/functions/helper.dart';

class AuthFunctions {
  AuthFunctions(this.context);
  final BuildContext context;
  late UserCredential userCredential;
  final db = APIs.db;
  final auth = APIs.auth;

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

  Future<String> putProfilePicturetoFirebaseStorage(XFile selectedImage) async {
    try {
      String downloadURL = await APIs.putFiletoFirebaseStorage(
          selectedImage, 'user_Image', userCredential.user!.uid);
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

  Future<void> createRecentMessage() async {
    await db.collection('recent_chats').doc(userCredential.user!.uid).set({
      'sender_id': userCredential.user!.uid,
      'to_uids': [], // Initialize to_uids as an empty list
    });
  }

  Future<void> addToUsername(String username) async {
    await db.collection('user_names').doc(username).set({
      'user_name': username,
    });
  }

  Future<void> saveDataToFirestore(
      String downloadURL, String enteredEmail, String enteredUsername) async {
    try {
      final Map<String, dynamic> data = {
        "user_name": enteredUsername,
        "email": enteredEmail,
        "uid": userCredential.user!.uid,
        "user_image": downloadURL,
        "created_at": Timestamp.now()
      };
      db.collection("users").doc(userCredential.user!.uid).set(data);
    } on Exception catch (err) {
      await userCredential.user!.delete();
      await APIs.storageRef
          .ref()
          .child('user_Image')
          .child(userCredential.user!.uid)
          .delete();
      if (context.mounted) {
        showSnackBarWithText(
          context,
          "Data could not be saved to firestore. Due to error: ${err.toString()}",
          const Duration(seconds: 5),
        );
      }
    }
  }

  Future<void> forgetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }
}
