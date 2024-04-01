import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/models/chat_messages.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/models/recent_chats.dart';
import 'package:chat_app/screen/to_user_profile_screen.dart';
import 'package:chat_app/widgets/message_card_widgets/message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class UserChatScreen extends StatefulWidget {
  UserChatScreen(this.toUser, {super.key});

  ChatUser? toUser;
  // static const route = "/notification-screen";

  @override
  _UserChatScreenState createState() => _UserChatScreenState();

  static _UserChatScreenState of(BuildContext context) =>
      context.findAncestorStateOfType<_UserChatScreenState>()!;
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _textController = TextEditingController();
  late Stream<QuerySnapshot<Map<String, dynamic>>> _myStream;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _appBarStream;
  late ChatUser currentStreamData;
  String hash = "";
  bool _emojiShowing = false,
      _isUploading = false,
      toUpdateRecentMessage = false,
      isMessageFound = false;
  List<Message> list = [];
  Message? lastMessageSentByCurrentUser;
  Message? lastMessageReceiveFromStream;
  XFile? selectedImage;
  List<XFile> selectedImages = [];
  String? downloadURL;
  final List<String> hintMessages = [
    "Feeling chatty? Spill the tea!",
    "Words of wisdom or witty banter?",
    "Hit send before your courage fades.",
    "Say something, I'm bored here!.",
    "Make my day with words!"
  ];
  String hintText = "";
  final random = Random();
  Map<String, dynamic>? toUserDataFromNotifcation;
  bool isUserComingFromNotificationLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.toUser != null) {
      _setupChat(widget.toUser!);
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    print("Userchat screen ${widget.toUser}");
    if (widget.toUser == null) {
      // Coming here from notification
      setState(() {
        isUserComingFromNotificationLoading = true;
      });
      final message =
          ModalRoute.of(context)?.settings.arguments as RemoteMessage?;
      print("Modal Message, $message");
      if (message != null) {
        print("Message UserChatScreen: ${message.toMap()}");
        print("Message UserChatScreen UID: ${message.data["uid"]}");
        await getParticularUserDataFromNotification(message.data["uid"])
            .then((_) {
          widget.toUser = ChatUser.fromJson(toUserDataFromNotifcation!);
          print("Message UserChatScreen ${widget.toUser!.toJson()}");
          _setupChat(widget.toUser!);
          localNotifcation.cancelAll();
          setState(() {
            isUserComingFromNotificationLoading = false;
          });
        });
      }
    }
    // else {
    //   _setupChat(widget.toUser!);
    // }
  }

  void _setupChat(ChatUser toUser) {
    hash = generateHash(currentUser!.uid, toUser.uid);
    _myStream = APIs.getAllMessagesBetweenUsers(hash);
    hintText = hintMessages[random.nextInt(hintMessages.length)];
    _appBarStream = APIs.getParticularUserSnapshot(widget.toUser!.uid);
  }

  Future<void> getParticularUserDataFromNotification(String uid) async {
    toUserDataFromNotifcation = await APIs.getParticularUserData(uid);
  }

  @override
  void dispose() {
    _textController.dispose();
    lastMessageSentByCurrentUser = null;
    super.dispose();
  }

  Future<void> marktheUnreadMessages(
      // Marks the unread messages as read for the given list of messages and hash.
      // It iterates through the messages, marks each unread message as read using the APIs.markMessageRead method,
      // and updates the recent message for both users if the message is the last one in the list.
      List<Message> messages,
      String hash) async {
    // print("heree");
    // lastMessageSentByCurrentUser = messages.reversed.last;
    for (Message message in messages.reversed) {
      if (message.senderId != currentUser!.uid && message.seen == false) {
        await APIs.markMessageRead(hash, message.messageId);
        message.seen = true;
        if (message == messages.reversed.last) {
          APIs.updateRecentMessageforBothUsers(currentUser!.uid,
              widget.toUser!.uid, messageToLastMessage(message));
        }
      }
    }
  }

  LastMessage messageToLastMessage(Message message) {
    // Converts a Message object to a LastMessage object by extracting its content, senderId, seen status, and sentAt time.
    return LastMessage(
        content: message.content,
        senderId: message.senderId,
        isRead: message.seen,
        time: message.sentAt,
        type: message.type);
  }

  void _pickImageAndUpload({bool isCamera = true}) async {
    // A function to pick an image either from the camera or gallery and send it to Firebase storage.
    selectedImages.clear();
    if (isCamera) {
      XFile? temp = await pickImageUsingImagePicker(isCamera: isCamera);
      if (temp != null) {
        selectedImages.add(temp);
      }
    } else {
      selectedImages = await pickMultiImageUsingImagePicker();
    }
    if (selectedImages.isEmpty) {
      return;
    } else {
      for (XFile image in selectedImages) {
        setState(() {
          _isUploading = true;
        });
        DateTime currentTime = DateTime.now();
        String downloadURL = await APIs.putFiletoFirebaseStorage(
            image,
            "chats/$hash",
            currentUser!.uid + currentTime.microsecondsSinceEpoch.toString());
        print(downloadURL);
        _createAndSendMessage(downloadURL, type: "image");
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _createAndSendMessage(String content, {String type = "text"}) {
    /// Creates and sends a message (that is stored on Firestore) with the given content and optional type.
    ///
    /// Parameters:
    ///   - content: The content of the message.
    ///   - type: The type of the message. Defaults to "text".
    ///
    /// Returns: None
    DateTime currentTime = DateTime.now();
    final Message message = Message(
        messageId: currentTime.microsecondsSinceEpoch.toString(),
        senderId: currentUser!.uid,
        content: content,
        sentAt: currentTime,
        type: type);
    APIs().sendMessageAndPushNotifcation(hash, message, currentStreamData);
    toUpdateRecentMessage = true;
    lastMessageSentByCurrentUser = message;
  }

  void _selectImage() {
    // Displays a modal bottom sheet with two image buttons: one for taking a photo and one for selecting an image from the gallery.
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      barrierColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildImageButton(
              assetPath: "assets/images/camera.gif",
              text: "Take Photo",
              onPressed: () {
                _pickImageAndUpload(isCamera: true);
                Navigator.pop(context);
              },
            ),
            _buildImageButton(
              assetPath: "assets/images/gallery.gif",
              text: "Select From Gallery",
              onPressed: () {
                _pickImageAndUpload(isCamera: false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print(
    //     "UserChatScreen ${widget.toUser}, $isUserComingFromNotificationLoading");
    if (widget.toUser == null || isUserComingFromNotificationLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    Size mq = MediaQuery.of(context).size;
    // print(Theme.of(context).colorScheme.background.withBlue(100).hex);

    return WillPopScope(
      onWillPop: () async {
        // This is done to minimize the API call, but we can call this directly, when user is sending message to see the immediate Recent message update.
        // That should be the case and then it will work as expected. It is here, just to minimize the API call.
        if (toUpdateRecentMessage ||
            lastMessageReceiveFromStream != lastMessageSentByCurrentUser) {
          // _isLastSentMessageSeen(list);
          await APIs.updateRecentMessageforBothUsers(
              widget.toUser!.uid,
              currentUser!.uid,
              messageToLastMessage(lastMessageReceiveFromStream!));
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
                    if (listOfMessages != null && listOfMessages.isNotEmpty) {
                      list = listOfMessages
                          .map((e) => Message.fromJson(e.data()))
                          .toList()
                          .cast<Message>();
                      marktheUnreadMessages(list, hash);
                      lastMessageReceiveFromStream = list.first;
                    }

                    if (list.isNotEmpty) {
                      isMessageFound = true;
                      return Expanded(
                        child: GroupedListView(
                          elements: list,
                          groupBy: (element) {
                            return DateTime.parse(DateFormat('yyyy-MM-dd')
                                .format(element.sentAt));
                          },
                          groupComparator: (DateTime value1, DateTime value2) =>
                              value2.compareTo(value1),
                          itemComparator:
                              (Message message1, Message message2) =>
                                  message2.sentAt.compareTo(message1.sentAt),
                          groupSeparatorBuilder: (value) => Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.2,
                                  vertical: 10),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 2),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(DateFormat.yMMMMd().format(value),
                                  textAlign: TextAlign.center)),
                          reverse: true,
                          // order: GroupedListOrder.ASC,
                          padding:
                              EdgeInsets.symmetric(vertical: mq.height * 0.01),
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, element) {
                            return MessageCard(
                              key: Key(element.messageId),
                              message: element,
                              hash: hash,
                              toUser: widget.toUser!,
                            );
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
            if (_isUploading)
              const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: CircularProgressIndicator(strokeWidth: 2))),
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
      titleSpacing: 0,
      title: StreamBuilder(
        stream: _appBarStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.data!.data() != null) {
              currentStreamData = ChatUser.fromJson(snapshot.data!.data()!);
              return Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(currentStreamData.userImage),
                  ),
                  SizedBox(
                    width: mq.width * 0.03,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          currentStreamData.name.isEmpty
                              ? currentStreamData.userName
                              : currentStreamData.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(
                          (currentStreamData.isOnline)
                              ? "Online"
                              : formatLastSeen(currentStreamData.lastActive!),
                          style: Theme.of(context).textTheme.titleSmall),
                    ],
                  )
                ],
              );
            } else {
              return const Expanded(
                child: Center(
                  child: Text("User could not be found."),
                ),
              );
            }
          }
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      OtherUserProfileScreen(toUser: currentStreamData)));
            },
            icon: const Icon(CupertinoIcons.info_circle_fill),
          ),
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
                  suffixIcon: IconButton(
                      onPressed: () {
                        _selectImage();
                        // FocusManager.instance.primaryFocus?.unfocus();
                        // setState(() {
                        //   _emojiShowing = !_emojiShowing;
                        // });
                      },
                      icon: const Icon(Icons.attach_file_outlined)),
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
                print("${currentUser!.uid}, ${widget.toUser!.uid}, $hash");
                final Chat chatData = Chat(
                    chatId: hash.toString(),
                    type: "Individual",
                    participants: [currentUser!.uid, widget.toUser!.uid]);
                APIs.createChat(chatData);
              }
              final String value = _textController.text;
              if (value.trim().isEmpty) {
                return;
              }
              _createAndSendMessage(value.trim());
              _textController.clear();
            },
          ),
        )
      ],
    );
  }

  Widget _buildImageButton({
    required String assetPath,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Stack(
      children: [
        InkWell(
          onTap: onPressed,
          child: Ink.image(
            height: 150,
            width: 150,
            image: AssetImage(assetPath),
            fit: BoxFit.cover, // Adjust fit as needed
          ),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
          ),
        ),
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
