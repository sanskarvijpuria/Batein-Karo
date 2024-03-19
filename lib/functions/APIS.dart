import 'dart:io' as io;
import 'package:chat_app/models/chat_messages.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/recent_chats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

ChatUser? currentUser;

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

  // ****************** Recent Chats *********************

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getAllRecentUsers(
      String currentUserUid) {
    var snapshot =
        db.collection("recent_chats").doc(currentUserUid).snapshots();
    return snapshot;
  }

  static Future<void> updateRecentMessage(
      String user1, String user2, LastMessage lastMessage) async {
    final docRef = FirebaseFirestore.instance
        .collection('recent_chats')
        .doc(user1); // Replace with the logged user's UID

    // Get the recent chats document
    final snapshot = await docRef.get();

    // Check if document exists (optional)
    if (!snapshot.exists) {
      // Create a new document if it doesn't exist
      await docRef.set({
        'sender_id': user1,
        'to_uids': [], // Initialize to_uids as an empty list
      });
    }

    final List<Map<String, dynamic>> toUids =
        snapshot.data()?['to_uids'].cast<Map<String, dynamic>>() ?? [];
    // Check if user already exists in the list

    final existingUserIndex =
        toUids.indexWhere((user) => user.keys.first == user2);

    if (existingUserIndex != -1) {
      // User exists, update their last_message details
      toUids[existingUserIndex][user2] = lastMessage.toJson();
    } else {
      // User doesn't exist, create a new entry
      toUids.add({
        user2: lastMessage.toJson(),
      });
    }

    // Update the document with the modified to_uids list
    await docRef.update({
      'to_uids': toUids,
    });
  }

  static Future<void> updateRecentMessageforBothUsers(String currentUserUid,
      String otherUserUid, LastMessage lastMessage) async {
    await updateRecentMessage(currentUserUid, otherUserUid, lastMessage);
    await updateRecentMessage(otherUserUid, currentUserUid, lastMessage);
  }

  // ****************** Messages ************************

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessagesBetweenUsers(
      String hash) {
    Stream<QuerySnapshot<Map<String, dynamic>>> data = db
        .collection("chats")
        .doc(hash.toString())
        .collection("messages")
        .orderBy("sent_at", descending: true)
        .snapshots();
    return data;
  }

  static Future<void> createChat(Chat chatData) {
    return db.collection("chats").doc(chatData.chatId).set(chatData.toJson());
  }

  static Future<void> sendMessage(String hash, Message message) {
    return db
        .collection("chats")
        .doc(hash.toString())
        .collection("messages")
        .doc(message.messageId)
        .set(message.toJson());
  }

  static Future<void> markMessageRead(String hash, String messageId) async {
    final docRef = db
        .collection('chats')
        .doc(hash)
        .collection('messages')
        .doc(messageId)
        .update({
      'seen': true,
    });
  }

  static Future<void> markAllMessagesRead(
      String hash, List<String> messagesIds) async {
    for (String messageId in messagesIds) {
      markMessageRead(hash, messageId);
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getLastMessages(
      String hash) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> data =
        db.collection("chats").doc(hash.toString()).snapshots();
    return data;
  }
}
