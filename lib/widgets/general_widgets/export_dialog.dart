import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/export.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/main.dart';

import 'package:chat_app/models/chat_user.dart';

import 'package:flutter/material.dart';

class ExportDataDialog extends StatelessWidget {
  ExportDataDialog({super.key, required this.currentUser});

  final ChatUser currentUser;

  bool enableYesButton = true;

  void durationTillLastExport() {
    if (currentUser.exportedDataAt == null) {
      return;
    }
    Duration differenceInTime =
        DateTime.now().difference(currentUser.exportedDataAt!);
    if (differenceInTime.compareTo(const Duration(days: 2)) < 0) {
      enableYesButton = false;
    }
  }

  void showDialog(BuildContext context) {
    showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: const AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            content: SizedBox(
              width: 300.0,
              height: 80.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Exporting...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    final double buttonHeight = mq.height * 0.05;
    final double buttonWidth = mq.width * 0.35;
    Size buttonSize = Size(buttonWidth, buttonHeight);
    durationTillLastExport();
    print("Export Data Yes Button $enableYesButton");
    // print(mq);
    return AlertDialog.adaptive(
      title: const Text(
        "Export Data",
        textAlign: TextAlign.center,
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
        height: (currentUser.exportedDataAt == null)
            ? mq.height * 0.13
            : mq.height * 0.20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Export Your Data to JSON File.",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Please note: ",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    TextSpan(
                      text:
                          "You will not be able to export data for the next 48 hours.",
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            if (currentUser.exportedDataAt != null)
              const SizedBox(
                height: 8,
              ),
            if (currentUser.exportedDataAt != null)
              Expanded(
                child: Text(
                  "Your last export date and time is ${formatJoinedDate(currentUser.createdAt!)}",
                  softWrap: true,
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
      actionsOverflowDirection: VerticalDirection.up,
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsOverflowButtonSpacing: 8,
      actionsPadding: const EdgeInsets.only(top: 8, right: 8, left: 8, bottom: 8),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          style: TextButton.styleFrom(fixedSize: buttonSize),
          child: const Text(
            "No",
            style: TextStyle(fontSize: 18),
          ),
        ),
        TextButton(
          onPressed: enableYesButton == false
              ? null
              : () async {
                  Navigator.pop(context, true);

                  showDialog(context);

                  await exportData().then((value) {
                    Navigator.pop(navigatorKey.currentContext!);
                    return value;
                  });
                },
          style: TextButton.styleFrom(fixedSize: buttonSize),
          child: const Text(
            "Yes",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
