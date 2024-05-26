import 'package:cached_network_image/cached_network_image.dart';
import 'package:batein_karo/functions/helper.dart';
import 'package:batein_karo/models/chat_user.dart';
import 'package:batein_karo/widgets/general_widgets/photo_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OtherUserProfileScreen extends StatelessWidget {
  final ChatUser toUser;
  const OtherUserProfileScreen({super.key, required this.toUser});

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 15,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(toUser.name),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            top: mq.height * 0.05,
            left: mq.width * 0.03,
            right: mq.width * 0.03,
            bottom: mq.height * 0.02),
        child: Column(
          children: [
            _buildProfilePicture(context, mq),
            SizedBox(height: mq.height * 0.03),
            _buildUserInfo(context, mq),
            SizedBox(height: mq.height * 0.01),
            _buildAboutSection(context),
            SizedBox(height: mq.height * 0.03),
            Expanded(child: _buildJoinedOn(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context, Size mq) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoViewer(
                image: CachedNetworkImageProvider(toUser.userImage),
                name: toUser.name.isEmpty
                    ? toUser.userName
                    : toUser.name,
                profileDialog: true,
                herotag: "profile_image_hero_tag",
              ),
            ),
          );
      },
      child: Hero(
        tag: "profile_image_hero_tag",
        transitionOnUserGestures: true,
        child: CircleAvatar(
          radius: mq.height * 0.12, // Fixed size for profile picture
          backgroundImage: CachedNetworkImageProvider(toUser.userImage),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, Size mq) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          toUser.name,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        SizedBox(height: mq.height * 0.001),
        Text(
          toUser.userName,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: mq.height * 0.002),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.circle_filled,
              size: 15.0,
              color: toUser.isOnline ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 5.0),
            Text(
              toUser.isOnline ? "Online" : formatLastSeen(toUser.lastActive!),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About",
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          alignment: Alignment.center,
          child: Text(
            toUser.about.isEmpty
                ? "User has not set up any About. Aalsi hai."
                : toUser.about,
            style: toUser.about.isEmpty
                ? Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.5))
                : Theme.of(context).textTheme.bodyLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildJoinedOn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Joined On: ',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.w500,
              fontSize: 15),
        ),
        Text(
          formatJoinedDate(toUser.createdAt!),
          style: TextStyle(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              fontSize: 15),
        ),
      ],
    );
  }
}
