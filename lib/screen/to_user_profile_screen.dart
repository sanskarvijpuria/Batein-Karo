import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OtherUserProfileScreen extends StatelessWidget {
  OtherUserProfileScreen({super.key, required this.toUser});
  late Size mq;
  final ChatUser toUser;

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
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
            right: mq.width * 0.03),
        child: Column(
          children: [
            _buildProfilePicture(),
            SizedBox(height: mq.height * 0.03),
            // Name
            Text(
              toUser.name,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            SizedBox(height: mq.height * 0.001),
            // User Name
            Text(
              toUser.userName,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: mq.height * 0.025),
            Text(
              formatLastSeen(toUser.lastActive!),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: mq.height * 0.025),
            Container(
              padding: const EdgeInsets.all(5),
              height: mq.height * 0.04,
              width: double.infinity,
              decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.05)),
              child: Text(
                toUser.about,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(height: mq.height * 0.01),
            Container(
              padding: const EdgeInsets.all(5),
              height: mq.height * 0.04,
              width: double.infinity,
              decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.05)),
              child: Text(
                toUser.about,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // Email
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Joined On: ',
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15),
                  ),
                  Text(
                      formatJoinedDate(
                        toUser.createdAt!,
                      ),
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 15)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      children: [
        CircleAvatar(
          radius: mq.height * 0.12,
          backgroundImage: Image.network(toUser.userImage).image,
        ),
      ],
    );
  }
}
