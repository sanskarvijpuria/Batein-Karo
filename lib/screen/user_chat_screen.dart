import 'dart:math';

import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/models/chat_messages.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/recent_chats.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen(this.toUser,
      {super.key});

  final ChatUser toUser;

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _textController = TextEditingController();
  late Stream _myStream;
  bool isMessageFound = false;
  String hash = "";
  bool toUpdateRecentMessage = false;
  bool _emojiShowing = false;
  List<Message> list = [];
  Message? lastMessageSentByCurrentUser;
  final List<String> hintMessages = [
    "Feeling chatty? Spill the tea!",
    "Words of wisdom or witty banter?",
    "Hit send before your courage fades.",
    "Say something, I'm bored here!.",
    "Make my day with words!"
  ];
  String hintText = "";
  final random = Random();

  @override
  void initState() {
    super.initState();
    hash = generateHash(currentUser!.uid, widget.toUser.uid);
    _myStream = APIs.getAllMessagesBetweenUsers(hash);
    hintText = hintMessages[random.nextInt(hintMessages.length)];
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> marktheUnreadMessages(
      List<Message> messages, String hash) async {
    print("heree");
    lastMessageSentByCurrentUser = messages.reversed.last;
    for (Message message in messages.reversed) {
      if (message.senderId != currentUser!.uid && message.seen == false) {
        await APIs.markMessageRead(hash, message.messageId);
        message.seen = true;
        if (message == messages.reversed.last) {
          APIs.updateRecentMessageforBothUsers(currentUser!.uid,
              widget.toUser.uid, messageToLastMessage(message));
        }
      }
    }
  }

  LastMessage messageToLastMessage(Message message) {
    return LastMessage(
        content: message.content,
        senderId: message.senderId,
        isRead: message.seen,
        time: message.sentAt);
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    print(Theme.of(context).colorScheme.background.withBlue(100).hex);

    return WillPopScope(
      onWillPop: () async {
        // This is done to minimize the API call, but we can call this directly, when user is sending message to see the immediate Recent message update.
        // That should be the case and then it will work as expected. It is here, just to minimize the API call.
        if (toUpdateRecentMessage) {
          // _isLastSentMessageSeen(list);
          await APIs.updateRecentMessageforBothUsers(
              widget.toUser.uid,
              currentUser!.uid,
              messageToLastMessage(lastMessageSentByCurrentUser!));
        }
        if (_emojiShowing) {
          setState(() {
            _emojiShowing = !_emojiShowing;
          });
          return false;
        }
        // Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(mq),
        body: Column(
          children: [
            StreamBuilder(
                stream: _myStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    final listOfMessages = snapshot.data?.docs;
                    list.clear();
                    list = listOfMessages
                            ?.map((e) => Message.fromJson(e.data()))
                            .toList()
                            ?.cast<Message>() ??
                        [];
                    marktheUnreadMessages(list, hash);
                    if (list.isNotEmpty) {
                      isMessageFound = true;
                      return Expanded(
                        child: ListView.builder(
                          reverse: true,
                          itemCount: list.length,
                          padding:
                              EdgeInsets.symmetric(vertical: mq.height * 0.01),
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return MessageCard(message: list[index]);
                          },
                        ),
                      );
                    } else {
                      return const Expanded(
                        child: Center(
                          child: Text("Say Hello 🙋‍♂️."),
                        ),
                      );
                    }
                  }
                }),
            _buildchatInput(hash),
            if (_emojiShowing) _selectEmoji(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(Size mq) {
    return AppBar(
      elevation: 15,
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              widget.toUser.userImage,
            ),
          ),
          SizedBox(
            width: mq.width * 0.02,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.toUser.name,
                  style: Theme.of(context).textTheme.titleLarge),
              Text(widget.toUser.userName,
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          )
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 15),
          child: Icon(CupertinoIcons.info_circle_fill),
        ),
      ],
    );
  }

  Widget _buildchatInput(String hash) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10,
            ),
            child: SingleChildScrollView(
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 5,
                onTap: () {
                  if (_emojiShowing) {
                    setState(() {
                      _emojiShowing = !_emojiShowing;
                    });
                  }
                },
                // onTapOutside: (event) {
                //   FocusManager.instance.primaryFocus?.unfocus();
                // },
                autocorrect: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: IconButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          _emojiShowing = !_emojiShowing;
                        });
                      },
                      icon: const Icon(Icons.emoji_emotions)),
                  suffixIcon: const Icon(Icons.attach_file_outlined),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (isMessageFound == false) {
                print(
                    "User is having conversion between each other for the first time");
                print("${currentUser!.uid}, ${widget.toUser.uid}, $hash");
                final Chat chatData = Chat(
                    chatId: hash.toString(),
                    type: "Individual",
                    participants: [currentUser!.uid, widget.toUser.uid]);
                APIs.createChat(chatData);
              }
              final String value = _textController.text;
              if (value.trim().isEmpty) {
                return;
              }
              DateTime currentTime = DateTime.now();
              final Message message = Message(
                  messageId: currentTime.microsecondsSinceEpoch.toString(),
                  senderId: currentUser!.uid,
                  content: value.trim(),
                  sentAt: currentTime);
              APIs.sendMessage(hash, message);
              toUpdateRecentMessage = true;
              lastMessageSentByCurrentUser = message;
              _textController.clear();
            },
          ),
        )
      ],
    );
  }

  Widget _selectEmoji() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {},
      onBackspacePressed: () {},
      textEditingController: _textController,
      config: Config(
        height: 300,
        emojiViewConfig: EmojiViewConfig(
            columns: 8,
            backgroundColor:
                Theme.of(context).colorScheme.background.lighten(25),
            replaceEmojiOnLimitExceed: true,
            buttonMode: ButtonMode.CUPERTINO),
        checkPlatformCompatibility: true,
        swapCategoryAndBottomBar: true,
        skinToneConfig: SkinToneConfig(
            dialogBackgroundColor: Theme.of(context).colorScheme.background,
            indicatorColor: Theme.of(context).colorScheme.onBackground),
        categoryViewConfig: const CategoryViewConfig(),
        bottomActionBarConfig: BottomActionBarConfig(
          backgroundColor: Theme.of(context).colorScheme.outlineVariant,
          buttonIconColor: Theme.of(context).colorScheme.outline,
          buttonColor: Theme.of(context).colorScheme.outlineVariant,
        ),
        searchViewConfig: const SearchViewConfig(),
      ),
    );
  }
}
