import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/recent_chats.dart';
import 'package:chat_app/widgets/home_screen_user_card.dart';
import 'package:chat_app/widgets/kebab_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false; // Flag for loading state
  List<List<dynamic>> recentUserDataWithLastMessage = [];
  Set<String> recentChatsUid = {};
  bool isRecentMessageUpdated = false;
  DocumentSnapshot<Map<String, dynamic>>? _previousStreamData;

  @override
  void initState() {
    super.initState();
    _getSelfData().then((value) {
      APIs.updateUserOnlineStatus(
          currentUser!.uid, true); // For the first time setting it as true;
    });

    SystemChannels.lifecycle.setMessageHandler((message) {
      print('System Message: ${message.toString()}');

      if (currentUser != null && message != null) {
        if (message.toString().toLowerCase().contains("resume")) {
          APIs.updateUserOnlineStatus(currentUser!.uid, true);
        }
        if (message.toLowerCase().contains("pause")) {
          APIs.updateUserOnlineStatus(currentUser!.uid, false);
        }
      }
      return Future.value(message);
    });
  }

  List<dynamic> sortUsersByLastMessageTime(List<dynamic> listOfDict) {
    // Sorts the list of dictionaries by the 'time' value of the inner dictionary and returns the sorted list.
    listOfDict.sort((a, b) {
      final timeA = a.values.first["time"] as Timestamp;
      final timeB = b.values.first["time"] as Timestamp;
      return timeB.compareTo(timeA);
    });
    return listOfDict;
  }

  Future<void> _recentChatUserData(List<dynamic> recentChatUserData) async {
    // A function that takes a list of dynamic recent chat user data, sorts them by last message time,
    // retrieves particular user data using APIs, constructs chat user and last message objects,
    // then updates the state with the recent user data and last messages.
    List<dynamic> sortedRecentUserList =
        sortUsersByLastMessageTime(recentChatUserData);
    List<List<dynamic>> chats = [];
    for (var data in sortedRecentUserList) {
      String userUID = data.keys.toList()[0];
      final userData = await APIs.getParticularUserData(userUID);
      chats.add(
          [ChatUser.fromJson(userData), LastMessage.fromJson(data[userUID])]);
      recentChatsUid.add(userUID);
    }
    setState(() {
      recentUserDataWithLastMessage = chats;
    });
  }

  Future<void> _getSelfData() async {
    // A function that retrieves the current user's data asynchronously and updates the UI accordingly.
    setState(() {
      isLoading = true;
    });
    try {
      ChatUser fetchedUser = await APIs.getSelfData();
      setState(() {
        currentUser = fetchedUser;
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching user data: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    Function eq = const DeepCollectionEquality.unordered().equals;
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.home),
        elevation: 15,
        title: const Text('Batein Karo'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.search),
          ),
          const KebabMenu(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add_comment_rounded),
        ),
      ),
      body: StreamBuilder(
          stream: APIs.getAllRecentUsers(currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              // print(snapshot.data?.data());
              // print(currentUser!.uid);
              final currentStreamData = snapshot.data;
              if (snapshot.data!.data() != null &&
                  snapshot.data!.get("to_uids") != []) {
                // List<dynamic> listOfUsers = snapshot.data!
                //     .get("to_uids")
                //     .map((dict) => dict.keys.first)
                //     .toList();
                // print("$listOfUsers, ${recentChatsUid.toList()}");
                // print(snapshot.data!.get("to_uids"));
                // if (!eq(listOfUsers, recentChatsUid.toList())) {
                //   _recentChatUserData(snapshot.data!.get("to_uids"));
                // }
                if (!eq(
                    currentStreamData?.data(), _previousStreamData?.data())) {
                  _previousStreamData = currentStreamData;
                  _recentChatUserData(snapshot.data!.get("to_uids"));
                }
              }
              if (recentUserDataWithLastMessage.isNotEmpty) {
                return ListView.builder(
                  itemCount: recentUserDataWithLastMessage.length,
                  padding: EdgeInsets.symmetric(vertical: mq.height * 0.01),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return HomeScreenChatUserCard(
                      mq: mq,
                      chatUser: recentUserDataWithLastMessage[index][0],
                      lastMessage: recentUserDataWithLastMessage[index][1],
                    );
                  },
                );
              } else {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Bhaii chat dhikane ke liye bhi kisi se bat karni padegi.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }
            }
          }),
    );
  }
}
