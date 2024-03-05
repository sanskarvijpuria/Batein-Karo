import 'dart:io' as io;
import 'package:chat_app/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class APIs {
  static FirebaseFirestore db = FirebaseFirestore.instance;
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseStorage storageRef = FirebaseStorage.instance;

  static Future<Map<String, dynamic>> getParticularUserData(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await db.collection("users").doc(uid).get();
      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      // Handle any errors
      print('Error getting user data: $e');
      return {};
    }
  }

  static Future<ChatUser> getSelfData() async {
    Map<String, dynamic> data =
        await getParticularUserData(auth.currentUser!.uid);
    return ChatUser.fromJson(data);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsersExceptMe() {
    Stream<QuerySnapshot<Map<String, dynamic>>> data = db
        .collection("users")
        .where("uid", isNotEqualTo: auth.currentUser!.uid)
        .snapshots();

    return data;
  }

  static Future<void> updateUserData(
      Map<String, dynamic> userData, String uid) {
    return db.collection("users").doc(uid).update(userData);
  }

  static Future<String> putFiletoFirebaseStorage(
      XFile selectedImage, String collectionName, String fileName) async {
    final storageRef =
        APIs.storageRef.ref().child(collectionName).child(fileName);
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
  }
}
