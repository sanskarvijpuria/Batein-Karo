import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/main.dart';

import 'package:chat_app/models/chat_user.dart';

import 'package:chat_app/screen/user_chat_screen.dart';
import 'package:flutter/material.dart';

class AddUserDialog extends StatelessWidget {
  const AddUserDialog({super.key, required this.alreadyConnectedUser});
  final List<ChatUser> alreadyConnectedUser;
  Future<bool> _checkUserIfAlreadyExists(String email) {
    // Check if email exists in alreadyConnectedUser list
    for (ChatUser user in alreadyConnectedUser) {
      if (email == user.email) {
        return Future.value(true); // User already exists
      }
    }
    return Future.value(false); // User not found locally
  }

  @override
  Widget build(BuildContext context) {
    String email = '';
    Size mq = MediaQuery.of(context).size;
    final double buttonHeight = mq.height * 0.05;
    final double buttonWidth = mq.width * 0.35;
    Size buttonSize = Size(buttonWidth, buttonHeight);
    return AlertDialog.adaptive(
      title: const Text(
        "Add User",
        textAlign: TextAlign.left,
      ),
      titlePadding:
          const EdgeInsets.only(top: 15, right: 20, left: 20, bottom: 0),
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onBackground,
      ),
      contentPadding: EdgeInsets.only(
        top: mq.height * 0.015,
        right: 20,
        left: 20,
        bottom: 10,
      ),
      content: SizedBox(
        width: 300,
        child: TextField(
          maxLines: null,
          onChanged: (value) => email = value.trim(),
          decoration: InputDecoration(
            hintText: 'Email Id',
            prefixIcon: const Icon(
              Icons.email,
              color: Colors.blue,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      actionsOverflowDirection: VerticalDirection.up,
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsOverflowButtonSpacing: 8,
      actionsPadding: const EdgeInsets.all(8),
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(fixedSize: buttonSize),
          icon: const Icon(Icons.close),
          label: const Text(
            "Cancel",
            style: TextStyle(fontSize: 16),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            if (email.isNotEmpty) {
              bool userExists = await _checkUserIfAlreadyExists(email);
              if (userExists) {
                // User already exists, show snackbar
                showSnackBarWithText(
                  navigatorKey.currentContext!,
                  'User already exists!',
                  const Duration(seconds: 3),
                );
              } else {
                // Check user existence on server
                final result = await APIs.checkUserExist(email);

                if (!result[0]) {
                  showSnackBarWithText(
                    navigatorKey.currentContext!,
                    'User does not Exists!',
                    const Duration(seconds: 3),
                  );
                } else {
                  Navigator.push(
                    navigatorKey.currentContext!,
                    MaterialPageRoute(
                      builder: (context) => UserChatScreen(result[1]),
                    ),
                  );

                  // Navigate to UserChatScreen
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(fixedSize: buttonSize),
          icon: const Icon(Icons.add),
          label: const Text(
            "Add",
            style: TextStyle(fontSize: 16),
          ),
        )
      ],
    );
  }
}