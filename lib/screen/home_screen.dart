import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:chat_app/widgets/kebab_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.home),
        elevation: 21,
        title: const Center(child: Text('Batein Karo')),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.search),
          ),
          KebabMenu(user: APIs.auth.currentUser!),
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
          stream: APIs.db.collection("users").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final listOfUsers = snapshot.data?.docs;
              var list = listOfUsers
                      ?.map((e) => ChatUser.fromJson(e.data()))
                      .toList() ??
                  [];
              if (list.isNotEmpty) {
                return ListView.builder(
                  itemCount: list.length,
                  padding: EdgeInsets.symmetric(vertical: mq.height * 0.01),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatUserCard(
                      mq: mq,
                      chatUser: list[index],
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text("No Chats Found"),
                );
              }
            }
          }),
    );
  }
}
