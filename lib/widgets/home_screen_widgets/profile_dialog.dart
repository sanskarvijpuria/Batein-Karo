import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screen/to_user_profile_screen.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.toUser});

  final ChatUser toUser;

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return AlertDialog.adaptive(
      title: Text(
        toUser.name,
        textAlign: TextAlign.center,
      ),
      titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 30,
          color: Theme.of(context).colorScheme.onBackground),
      contentPadding: EdgeInsets.only(
          top: mq.height * 0.015, right: 20, left: 20, bottom: 10),

      content: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: toUser.userImage,
            imageBuilder: (context, imageProvider) => Container(
              width: mq.height * 0.50,
              height: mq.height * 0.35,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                shape: BoxShape.circle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Positioned(
            bottom: 0,
            right: 5,
            child: IconButton.filled(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => OtherUserProfileScreen(toUser: toUser),
                ),
              ),
              icon: const Icon(Icons.info_outline_rounded),
              constraints: const BoxConstraints(),
              iconSize: 20,
            ),
          )
        ],
      ),
    );
  }
}
