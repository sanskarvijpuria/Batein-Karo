import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/models/messages.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardCardState();
}

class _MessageCardCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    final bool isSender = widget.message.senderId == currentUser!.uid;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    Size mq = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      alignment: isSender ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        constraints: BoxConstraints(
          minWidth: mq.width * 0.2,
          maxWidth: mq.width * 0.8
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSender
              ? colorScheme.primaryContainer
              : colorScheme.tertiaryContainer,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 15, left: 15, right: 15),
              child: Text(
                widget.message.content,
                style: TextStyle(
                  fontSize: 15,
                  color: isSender
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onTertiaryContainer,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                children: [
                  Text(
                    extractTimeFromDateTime(widget.message.sentAt),
                    style: TextStyle(
                        fontSize: 12,
                        color: isSender
                            ? colorScheme.onPrimaryContainer.withOpacity(0.5)
                            : colorScheme.onTertiaryContainer.withOpacity(0.5)),
                  ),
                  if (isSender) ...[
                    const SizedBox(width: 5),
                    if (widget.message.seen == false)
                      const Icon(Icons.done, size: 12),
                    if (widget.message.seen)
                      const Icon(Icons.done_all, size: 12)
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
