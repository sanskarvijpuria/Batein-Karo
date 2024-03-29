import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/recent_chats.dart';
import 'package:chat_app/screen/home_screen.dart';
import 'package:chat_app/widgets/home_screen_user_card.dart';
import 'package:flutter/material.dart';

class RecentChatsList extends StatelessWidget {
  List<String> recentChatsUid = [];
  bool isSearching = false;
  List<dynamic> sortedRecentUserList = [];
  List<List<dynamic>>? searchList = [];
  List<ChatUser> sortedListOfChatUsers = [];
  // Add other necessary data as parameters

  RecentChatsList({
    super.key,
    required this.recentChatsUid,
    required this.sortedRecentUserList,
    this.isSearching = false,
    this.searchList,
    // Add other data parameters
  });

  List<ChatUser> sortChatUserBasedOnRecentUids(
      List<Map<String, dynamic>> listOfUsersData, List<String> listOfUIDs) {
    List<ChatUser> listOfChatUser = [];
    for (String uid in listOfUIDs) {
      for (Map<String, dynamic> userData in listOfUsersData) {
        if (userData["uid"] == uid) {
          listOfChatUser.add(ChatUser.fromJson(userData));
        }
      }
    }
    return listOfChatUser;
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: APIs.getUsersIfTheyAreinList(recentChatsUid.toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.none) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> data =
                snapshot.data!.docs.map((snapshot) => snapshot.data()).toList();
            sortedListOfChatUsers =
                sortChatUserBasedOnRecentUids(data, recentChatsUid.toList());
            HomeScreen.of(context).sortedListOfChatUsers =
                sortedListOfChatUsers;
            return ListView.builder(
              itemCount: isSearching
                  ? searchList!.length
                  : sortedListOfChatUsers.length,
              padding: EdgeInsets.symmetric(vertical: mq.height * 0.01),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (isSearching) {
                  return HomeScreenChatUserCard(
                    mq: mq,
                    chatUser: searchList![index][0],
                    lastMessage: LastMessage.fromJson(searchList![index][1]),
                  );
                } else {
                  String currentUID = recentChatsUid.toList()[index];
                  // print(sortedRecentUserList[index][currentUID]);
                  // print("Lastmessage ${LastMessage.fromJson(
                  //       sortedRecentUserList[index][currentUID])}");
                  return HomeScreenChatUserCard(
                    mq: mq,
                    chatUser: sortedListOfChatUsers[index],
                    lastMessage: LastMessage.fromJson(
                        sortedRecentUserList[index][currentUID]),
                  );
                }
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      },
    );
  }
}
