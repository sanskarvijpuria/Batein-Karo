import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/models/messages.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

    Widget content = Text(
      widget.message.content,
      style: TextStyle(
        fontSize: 15,
        color: isSender
            ? colorScheme.onPrimaryContainer
            : colorScheme.onTertiaryContainer,
      ),
    );

    if (widget.message.type == "image") {
      content = CachedNetworkImage(
        imageUrl: widget.message.content,
        placeholder: (context, url) => const Icon(Icons.image),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        imageBuilder: (context, imageProvider) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.onBackground),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Image(
                image: imageProvider,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
        width: 200,
        height: 200,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      alignment: isSender ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        constraints:
            BoxConstraints(minWidth: mq.width * 0.2, maxWidth: mq.width * 0.8),
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
              padding: (widget.message.type == "image")
                  ? const EdgeInsets.only(
                      top: 5.0, bottom: 20, left: 7.5, right: 7.5)
                  : const EdgeInsets.only(
                      top: 10.0, bottom: 15, left: 15, right: 15),
              child: content,
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
                            ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                            : colorScheme.onTertiaryContainer.withOpacity(0.7)),
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
