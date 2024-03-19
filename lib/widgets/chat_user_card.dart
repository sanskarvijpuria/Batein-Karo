import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/recent_chats.dart';
import 'package:chat_app/screen/user_chat_screen.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard(
      {super.key,
      required this.mq,
      required this.chatUser,
      required this.lastMessage,});
  final Size mq;
  final ChatUser chatUser;
  final LastMessage lastMessage;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Color getUnreadMessageColor(BuildContext context) {
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
      color: (widget.lastMessage.isRead != true) && (widget.lastMessage.senderId != currentUser!.uid)
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
            backgroundImage: NetworkImage(
              widget.chatUser.userImage,
            ),
          ),
          title: Text(widget.chatUser.name, style: const TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text(
            widget.lastMessage.content!,
            maxLines: 1,
          ),
          trailing: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8,
                bottom: 20),
                child: Text(
                  extractTimeFromDateTime(widget.lastMessage.time!),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              if(widget.lastMessage.senderId == currentUser!.uid)
              Positioned(
                bottom: 0,
                right: 5,
                child: Icon(
                  color: Colors.blueAccent.shade700,
                  widget.lastMessage.isRead != true ? Icons.done : Icons.done_all,
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
