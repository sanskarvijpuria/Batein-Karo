import 'package:batein_karo/functions/APIS.dart';
import 'package:batein_karo/functions/helper.dart';
import 'package:batein_karo/models/messages.dart';
import 'package:flutter/material.dart';

class EditMessageDialog extends StatefulWidget {
  const EditMessageDialog(
      {super.key, required this.message, required this.hash});
  final Message message;
  final String hash;

  @override
  State<EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<EditMessageDialog> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController.fromValue(
        TextEditingValue(text: widget.message.content));
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    final double buttonHeight = mq.height * 0.05;
    final double buttonWidth = mq.width * 0.35;
    Size buttonSize = Size(buttonWidth, buttonHeight);
    return AlertDialog.adaptive(
      title: const Text(
        "Edit message",
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
          controller: _textController,
          maxLines: null,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.edit_note,
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
            final String newValue = _textController.value.text.trim();
            if (newValue != widget.message.content && newValue.isEmpty) {
              await APIs.editMessage(
                      widget.hash, widget.message, _textController.value.text)
                  .then((value) {
                Navigator.of(context).pop();
              });
            } else {
              Navigator.of(context).pop();
              showSnackBarWithText(
                  context,
                  "Your value is either empty or you have not udpdated the message",
                  const Duration(seconds: 3));
            }
          },
          style: ElevatedButton.styleFrom(fixedSize: buttonSize),
          icon: const Icon(Icons.add),
          label: const Text(
            "Submit",
            style: TextStyle(fontSize: 16),
          ),
        )
      ],
    );
  }
}
