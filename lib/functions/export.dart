import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';

Future<void> saveFileFromWebToExternalDirectory(String path, String filename,
    {String url = "", bool isWebContent = true, String stringData = ""}) async {
  // Get External Directory
  final Directory? tempDir = await getExternalStorageDirectory();
  late Uint8List userResponseData;

  // Check whether we need to download the data from the web or the string data has been provided.
  // In future can be modified or removed to create a new function where string data can be downloaded from web.
  if (isWebContent) {
    userResponseData = await getResponseBytesFromUri(url);
  }

  // Creating directory if it does not exist.
  await Directory('${tempDir!.path}/$path/').create(recursive: true);

  // finally saving it
  if (isWebContent) {
    await File('${tempDir!.path}/$path/$filename')
        .writeAsBytes(userResponseData);
  } else {
    await File('${tempDir!.path}/$path/$filename').writeAsString(stringData);
  }
}

Future<Map<String, dynamic>> getFormattedUserDataForExport() async {
  // Getting user data
  Map<String, dynamic> userData =
      await APIs.getSelfData().then((value) => value!.toJson());

  await saveFileFromWebToExternalDirectory("export/images", "my_image.jpg",
      url: userData["user_image"]);

  List<String> fieldToRemove = [
    "is_online",
    "last_active",
    "push_token",
    "exported_data_at"
        "uid"
  ];
  for (String field in fieldToRemove) {
    userData.remove(field);
  }
  userData.update("user_image", (value) => "/images/my_image.jpg");
  userData.update("created_at", (value) => value.toString());
  // print(userData);
  return userData;
}

Future<List<String>> getListOfRecentChatsUIDForExport() async {
  final Map<String, dynamic> recentChats =
      await APIs.getAllRecentUsersForExport(currentUser!.uid)
          .then((value) => value.data()!);
  List<String> recentChatsUid = [];
  List<dynamic> sortedRecentUserList =
      sortUsersByLastMessageTime(recentChats["to_uids"]);
  for (var data in sortedRecentUserList) {
    String userUID = data.keys.toList()[0];
    recentChatsUid.add(userUID);
  }
  return recentChatsUid;
}

Future<List<Map<String, dynamic>>> getListofDictOfMessagesForExport(
    String hash) async {
  final messagesSnapshot = await APIs.getAllMessagesBetweenUsersForExport(hash)
      .then((value) => value.docs);
  final listOfMessagesDict = messagesSnapshot
      .map(
        (eachMessaageSnapshot) => eachMessaageSnapshot.data(),
      )
      .toList();
  return listOfMessagesDict;
}

Future<List<Map<String, dynamic>>> restructureFormat(
    List<Map<String, dynamic>> listOfMessagesDict,
    String toUserName,
    String toUserUids,
    String cuids) async {
  for (Map<String, dynamic> msg in listOfMessagesDict) {
    Message message = Message.fromJson(msg);
    msg.update("sent_at", (value) => message.sentAt.toString());
    msg.update("sender_id", (value) {
      if (value == cuids) {
        return "You";
      } else {
        return toUserName;
      }
    });
    msg.remove("seen_at");
    msg.remove("seen");
    msg.remove("edited_at");
    if (message.type.contains("image")) {
      await saveFileFromWebToExternalDirectory(
          "export/images/$toUserName", "${message.messageId}.jpg",
          url: message.content);
      msg.update(
          "content", (value) => "images/$toUserName/${message.messageId}.jpg");
    }
  }
  return listOfMessagesDict;
}

void zipFiles(String sourcePath) {
  final encoder = ZipFileEncoder();
  Directory dir = Directory(sourcePath);
  encoder.zipDirectory(dir, filename: '${dir.parent.path}/export.zip');
  // encoder.close();
}


Future<bool> exportData() async {
  final Map<String, dynamic> result = {};
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> resultMessages = [];

  try {
    final Directory? tempDir = await getExternalStorageDirectory();
    // Removing Existing Directory is exist

    String exportPath = "${tempDir!.absolute.path}/export/";
    Directory export = Directory(exportPath);
    if (export.existsSync()) {
      Directory(exportPath).deleteSync(recursive: true);
    }

    String zipFilePath = "${tempDir.absolute.path}/export.zip";
    if (File(zipFilePath).existsSync()) {
      File("${tempDir.absolute.path}/export.zip").deleteSync(recursive: true);
    }
    userData = await getFormattedUserDataForExport();
    print("Export $userData");

    String cuid = currentUser!.uid;

    // Get Recents Chat
    List<String> recentChatsUid = await getListOfRecentChatsUIDForExport();

    // Get Chats
    for (String recentChatUid in recentChatsUid) {
      print("Export $recentChatUid");
      String hash = generateHash(cuid, recentChatUid);
      ChatUser toUser = await APIs.getParticularUserData(recentChatUid)
          .then((value) => ChatUser.fromJson(value));
      // print("Export $to_user");
      var listOfMessagesDict = await getListofDictOfMessagesForExport(hash);

      listOfMessagesDict = await restructureFormat(
          listOfMessagesDict, toUser.userName, toUser.uid, cuid);

      // print(listOfMessagesDict);
      resultMessages.add({
        toUser.email: {
          "name": "${toUser.name}_2",
          "user_name": toUser.userName,
          "email": toUser.email,
          "messages": listOfMessagesDict
        }
      });
    }
    // print("$resultMessages");

    //Final Body Creation
    result.addAll(userData);
    result.addAll({"chats": resultMessages});
    print(json.encode(result));

    //Final Export

    String jsonString = jsonEncode(result);
    await saveFileFromWebToExternalDirectory("export/data", "export_data.txt",
        isWebContent: false, stringData: jsonString);
    zipFiles(exportPath);
    await APIs.updateUserData(
            {"exported_data_at": Timestamp.now()}, currentUser!.uid)
        .then((value) async {
      await APIs.getSelfData();
      showSnackBarWithText(
          navigatorKey.currentContext!,
          "Data has been successfully exported. Please check in the directory: $exportPath ",
          const Duration(seconds: 8));
    });
    return true;
  } on Exception catch (err, stacktrace) {
    // TODO
    print(err);
    print(stacktrace);
    showSnackBarWithText(
        navigatorKey.currentContext!,
        "Some Error Occured. Please try again later. Error is $err",
        const Duration(seconds: 3));
    return false;
  }
}
