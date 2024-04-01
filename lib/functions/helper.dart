import 'dart:convert';
import 'package:chat_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:permission_handler/permission_handler.dart';
import "package:universal_html/html.dart" as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:http/http.dart' as http;

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

String formatDateTime(DateTime datetime,
    {String prefixForToday = 'Today',
    String prefixForYesterday = 'Yesterday',
    String prefixForRest = "",
    bool showTimeForDatesOlder = false}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final String result;
  if (datetime.isAfter(today)) {
    result = '$prefixForToday ${DateFormat('HH:mm').format(datetime)}';
  } else if (datetime.isAfter(yesterday)) {
    result = '$prefixForYesterday ${DateFormat('HH:mm').format(datetime)}';
  } else if (now.year == datetime.year) {
    if (showTimeForDatesOlder) {
      result = '$prefixForRest ${DateFormat('d MMM HH:mm').format(datetime)}';
    } else {
      result = '$prefixForRest ${DateFormat('d MMM').format(datetime)}';
    }
  } else {
    if (showTimeForDatesOlder) {
      result = '$prefixForRest ${DateFormat('d MMM y HH:mm').format(datetime)}';
    } else {
      result = '$prefixForRest ${DateFormat('d MMM y').format(datetime)}';
    }
  }
  return result.trim();
}

String formatLastSeen(DateTime datetime) {
  return formatDateTime(datetime,
      prefixForRest: "Last seen on",
      prefixForToday: "Last seen today at",
      prefixForYesterday: "Last seen yesterday at");
}

String formatJoinedDate(DateTime datetime) {
  return formatDateTime(datetime,
      prefixForRest: "",
      prefixForToday: "Today at",
      prefixForYesterday: "Yesterday at");
}

String formatMessageSentTime(DateTime datetime) {
  return formatDateTime(datetime,
      prefixForRest: "",
      prefixForToday: "Today at",
      prefixForYesterday: "Yesterday at",
      showTimeForDatesOlder: true);
}

String formatLastMessageTimeForRecentMessage(DateTime datetime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);

  if (datetime.isAfter(today)) {
    return DateFormat('HH:mm').format(datetime);
  } else if (datetime.isAfter(yesterday)) {
    return 'Yesterday';
  } else {
    return DateFormat('d/MM/y').format(datetime);
  }
}

Future<XFile?> pickImageUsingImagePicker(
    {bool isCamera = true, int imageQuality = 100}) async {
  XFile? selectedImage;
  if (isCamera) {
    selectedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: imageQuality);
  } else {
    selectedImage = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: imageQuality);
  }
  return selectedImage;
}

Future<List<XFile>> pickMultiImageUsingImagePicker(
    {int imageQuality = 100}) async {
  List<XFile> selectedImages;
  selectedImages =
      await ImagePicker().pickMultiImage(imageQuality: imageQuality);
  return selectedImages;
}

String generateHash(String s1, String s2) {
  String sortedString = (<String>[s1, s2]..sort()).join();
  var bytes = utf8.encode(sortedString);
  String generatedHash = md5.convert(bytes).toString();
  print("Generating hash: $s1, $s2, $generatedHash");
  return generatedHash;
}

void dowloadImageFromWeb(
  List<int> bytes, {
  String? downloadName,
}) {
  // Encode our file in base64
  final _base64 = base64Encode(bytes);
  // Create the link with the file
  final anchor =
      html.AnchorElement(href: 'data:application/octet-stream;base64,$_base64')
        ..target = 'blank';
  // add the name
  if (downloadName != null) {
    anchor.download = downloadName;
  }
  // trigger download
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  return;
}

Future<void> downloadImage(BuildContext context, String content) async {
  try {
    print("IMAGE URL ${content}");
    if (kIsWeb) {
      await http.get(Uri.parse(content)).then((res) {
        dowloadImageFromWeb(res.bodyBytes,
            downloadName: "${DateTime.now()}.jpg");
      });
    } else {
      if (await Permission.photos.isGranted) {
        await GallerySaver.saveImage("$content.jpg", albumName: "Batein Karo")
            .then(
          (success) {
            if (success != null) {
              showSnackBarWithText(context, "Image saved to Gallery",
                  const Duration(seconds: 3));
            }
          },
        );
      } else {
        showSnackBarWithText(
          navigatorKey.currentContext!,
          "Please Provide Photos Permission",
          const Duration(seconds: 3),
        );
        await Permission.photos.shouldShowRequestRationale;
      }
    }
  } on Exception catch (err) {
    print("Error in Saving Image , $err");
  } finally {
    Navigator.pop(context);
  }
}

bool hasOnlyEmojis(String input) {
  // find all emojis
  final emojis = EmojiParser().parseEmojis(input);

  // return if none found
  if (emojis.isEmpty) return false;

  // remove all emojis from the input
  for (final emoji in emojis) {
    input = input.replaceAll(emoji, "");
  }

  // remove all whitespace (optional)
  input = input.replaceAll(" ", "");

  // return true if nothing else left
  return input.isEmpty;
}
