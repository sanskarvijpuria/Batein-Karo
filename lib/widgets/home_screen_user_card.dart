import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/recent_chats.dart';
import 'package:chat_app/screen/user_chat_screen.dart';
import 'package:flutter/material.dart';

class HomeScreenChatUserCard extends StatefulWidget {
  const HomeScreenChatUserCard({
    super.key,
    required this.mq,
    required this.chatUser,
    required this.lastMessage,
  });
  final Size mq;
  final ChatUser chatUser;
  final LastMessage lastMessage;

  @override
  State<HomeScreenChatUserCard> createState() => _HomeScreenChatUserCardState();
}

class _HomeScreenChatUserCardState extends State<HomeScreenChatUserCard> {
  Color getUnreadMessageColor(BuildContext context) {
    // A function that returns the color of unread messages based on the brightness of the theme.
    // Takes a BuildContext as a parameter.
    // Returns a Color.
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      return Colors.grey[500]!.withOpacity(0.3); // Adjust color for dark mode
    } else {
      return Colors.blueGrey[100]!; // Adjust color for light mode
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          EdgeInsets.symmetric(horizontal: widget.mq.width * 0.02, vertical: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0.5,
      color: (widget.lastMessage.isRead != true) &&
              (widget.lastMessage.senderId != currentUser!.uid)
          ? getUnreadMessageColor(context)
          : null,
      child: InkWell(
        onTap: () async {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return UserChatScreen(widget.chatUser);
            }),
          );
        },
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: CachedNetworkImageProvider(
              widget.chatUser.userImage,
            ),
          ),
          title: Text(
            widget.chatUser.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            (widget.lastMessage.type == "text")
                ? widget.lastMessage.content!
                : "IMAGE AAYA HAI BRO.",
            maxLines: 1,
          ),
          trailing: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                child: Text(
                  formatLastMessageTimeForRecentMessage(
                      widget.lastMessage.time!),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              if (widget.lastMessage.senderId == currentUser!.uid)
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: Icon(
                    color: Colors.blueAccent.shade700,
                    widget.lastMessage.isRead != true
                        ? Icons.done
                        : Icons.done_all,
                    size: 15,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
