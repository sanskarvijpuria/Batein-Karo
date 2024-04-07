import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/widgets/home_screen_widgets/add_user_dialog.dart';
import 'package:chat_app/widgets/general_widgets/kebab_menu.dart';
import 'package:chat_app/widgets/home_screen_widgets/home_screen_recent_user_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static _HomeScreenState of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeScreenState>()!;
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false, isError = false; // Flag for loading state
  List<String> recentChatsUid = [];
  bool _isSearching = false;
  final List<List<dynamic>> _searchList = [];
  List<dynamic> sortedRecentUserList = [];
  List<ChatUser> sortedListOfChatUsers = [];

  @override
  void initState() {
    super.initState();

    SystemChannels.lifecycle.setMessageHandler((message) async {
      print('System Message: ${message.toString()}');
      if (currentUser != null && message != null) {
        if (message.toString().toLowerCase().contains("resume")) {
          await APIs.db.enableNetwork();
          await APIs.updateUserOnlineStatus(currentUser!.uid, true);
        } else if (message.toLowerCase().contains("pause")) {
          await APIs.updateUserOnlineStatus(currentUser!.uid, false);
          await APIs.db.disableNetwork();
        } else if (message.toLowerCase().contains("detached")) {
          await APIs.updateUserOnlineStatus(currentUser!.uid, false);
          await APIs.db.disableNetwork();
        }
      }
      return Future.value(message);
    });
  }

  void _recentChatUserData(List<dynamic> recentChatUserData) {
    // A function that takes a list of dynamic recent chat user data, sorts them by last message time,
    // retrieves particular user data using APIs, constructs chat user and last message objects,
    // then updates the state with the recent user data and last messages.
    recentChatsUid = [];
    sortedRecentUserList = sortUsersByLastMessageTime(recentChatUserData);
    for (var data in sortedRecentUserList) {
      String userUID = data.keys.toList()[0];
      recentChatsUid.add(userUID);
    }
  }

  Future<void> _getSelfData() async {
    // A function that retrieves the current user's data asynchronously and updates the UI accordingly.
    setState(() {
      isLoading = true;
    });
    try {
      await APIs.getSelfData().then((fetchedUser) {
        if (fetchedUser == null) {
          throw "Data not Found.";
        } else {
          currentUser = fetchedUser;
        }
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
    return FutureBuilder(
        future: _getSelfData(),
        builder: (context1, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // isLoading = true;
            // Display loading indicator (e.g., CircularProgressIndicator())
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // isError = true;
            // Display error message or retry option
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "You are getting a error. Please don't hurt the developer. He is stupid. This is happening: User is not able to get the logged in user data. Please try again in sometime. Error: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            );
          } else {
            Future.delayed(Duration.zero, () async {
              await APIs.updateUserOnlineStatus(currentUser!.uid, true);
              final permissionStatusforPhotos =
                  await Permission.photos.request();
              final permissionStatusforMediaLocation =
                  await Permission.mediaLibrary.request();
              // final permissionStatusForStorage = await Permission.manageExternalStorage.request();
              print(
                  "permissionStatusforPhotos ${permissionStatusforPhotos.toString()}");
              print(
                  "permissionStatusforMediaLocation ${permissionStatusforMediaLocation.toString()}");
              // print("permissionStatusForStorage ${permissionStatusForStorage.toString()}");
              final notificationSettings = await APIs.askForPermission();
              if (notificationSettings.authorizationStatus ==
                  AuthorizationStatus.authorized) {
                final pushToken = await APIs.getPushToken();
                if (pushToken != null) {
                  print("PushToken: $pushToken");
                  if (currentUser!.pushToken != pushToken) {
                    await APIs.updateUserData(
                        {"push_token": pushToken}, currentUser!.uid);
                  }
                  // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
                  initPushNotifications();
                }
              }
            });

            return Scaffold(
              appBar: AppBar(
                titleSpacing: 0,
                leading: const Icon(CupertinoIcons.home),
                elevation: 15,
                title: _isSearching
                    ? TextField(
                        decoration: const InputDecoration(
                          hintText: 'Name, Email, ...',
                          hintStyle:
                              TextStyle(fontSize: 10, letterSpacing: 0.5),
                        ),
                        autofocus: true,
                        style:
                            const TextStyle(fontSize: 10, letterSpacing: 0.5),
                        //when search text changes then updated search list
                        onChanged: (val) {
                          //search logic
                          _searchList.clear();
                          print("Before Search list $val $_searchList");
                          for (int i = 0;
                              i < sortedListOfChatUsers.length;
                              i++) {
                            ChatUser chat = sortedListOfChatUsers[i];
                            if (chat.name
                                    .toLowerCase()
                                    .contains(val.toLowerCase()) ||
                                chat.userName
                                    .toLowerCase()
                                    .contains(val.toLowerCase())) {
                              for (Map<String, dynamic> recentUser
                                  in sortedRecentUserList) {
                                String userUID = recentUser.keys.toList()[0];
                                if (chat.uid == userUID) {
                                  _searchList.add([chat, recentUser[userUID]]);
                                }
                              }
                              print("After Search list $val $_searchList");
                            }
                          }
                          setState(() {
                            print("On changed call $val $_searchList");
                            _searchList;
                          });
                        },
                      )
                    : const Text('Batein Karo'),
                centerTitle: true,
                actions: [
                  // IconButton(
                  //   onPressed: () {
                  //     setState(() {
                  //       _isSearching = !_isSearching;
                  //     });
                  //   },
                  //   icon: Icon(_isSearching
                  //       ? CupertinoIcons.clear_circled_solid
                  //       : Icons.search),
                  // ),
                  KebabMenu(),
                ],
              ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: FloatingActionButton(
                  onPressed: () {
                    showAdaptiveDialog(
                      context: context,
                      builder: (context) {
                        return AddUserDialog(
                          alreadyConnectedUser: sortedListOfChatUsers,
                        );
                      },
                    );
                  },
                  child: const Icon(Icons.add_comment_rounded),
                ),
              ),
              body: StreamBuilder(
                stream: APIs.getAllRecentUsers(currentUser!.uid),
                builder: (context, snapshot) {
                  if (!kIsWeb) localNotifcation.cancelAll();
                  // if (!kIsWeb) exportData();
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.data!.data() != null &&
                        snapshot.data!.get("to_uids").isNotEmpty) {
                      List<dynamic> data = snapshot.data!.get("to_uids");
                      _recentChatUserData(data);
                      return RecentChatsList(
                        recentChatsUid: recentChatsUid,
                        sortedRecentUserList: sortedRecentUserList,
                        isSearching: _isSearching,
                        searchList: _searchList,
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
                },
              ),
            );
          }
        });
  }
}
