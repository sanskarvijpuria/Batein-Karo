import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/widgets/message_card_widgets/edit_message_dialog.dart';
import 'package:chat_app/widgets/message_card_widgets/option_items.dart';
import 'package:chat_app/widgets/general_widgets/photo_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

class MessageCard extends StatefulWidget {
  const MessageCard(
      {super.key,
      required this.message,
      required this.hash,
      required this.toUser});
  final Message message;
  final String hash;
  final ChatUser toUser;

  @override
  State<MessageCard> createState() => _MessageCardCardState();
}

class _MessageCardCardState extends State<MessageCard>
    with TickerProviderStateMixin {
  bool isArrowButtonActive = false;
  bool hasOnlyOneEmoji = false;
  bool hasOnlyMultipleEmojis = false;
  bool isHeartEmoji = false;
  double fontSize = 18;
  late AnimationController animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )
      ..forward()
      ..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(CurvedAnimation(
        parent: animationController, curve: Curves.bounceInOut));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _showBottomSheet(Size mq, bool isSender) {
    Widget divider = Divider(
      color: Theme.of(context).dividerColor.withOpacity(0.2),
    );

    // To show edit button or not. Depending on the various conditions.
    // Content should be text sent within 15 minutes.
    DateTime currentTime = DateTime.now();
    bool toShowEditButton = (widget.message.type == "text" &&
            isSender &&
            currentTime.difference(widget.message.sentAt).inMinutes <= 15)
        ? true
        : false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      showDragHandle: true,
      // constraints: BoxConstraints(maxHeight: mq.height * 0.45),
      enableDrag: true,
      isScrollControlled: true,
      // barrierColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10.0, left: 10, right: 10, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.message.type == "text")
                OptionItem(
                  icon: Icon(
                    Icons.copy_all_rounded,
                    color: Colors.blue.shade800,
                    size: 30,
                  ),
                  name: "Copy",
                  onTap: () async {
                    await Clipboard.setData(
                            ClipboardData(text: widget.message.content))
                        .then((value) {
                      Navigator.pop(context);
                      showSnackBarWithText(
                          context,
                          "Message is copied to your clipboard.",
                          const Duration(seconds: 3));
                    });
                  },
                ),
              if (widget.message.type == "image")
                OptionItem(
                    icon: Icon(
                      Icons.save_alt_rounded,
                      color: Colors.blue.shade800,
                      size: 30,
                    ),
                    name: "Save image",
                    onTap: () async {
                      await downloadImage(context, widget.message.content);
                    }),
              divider,
              if (toShowEditButton)
                OptionItem(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blue.shade800,
                    size: 30,
                  ),
                  name: "Edit message",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditMessageDialog(
                          message: widget.message, hash: widget.hash),
                    ));
                  },
                ),
              if (isSender)
                OptionItem(
                  icon: Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red.shade800,
                    size: 30,
                  ),
                  name: "Delete message",
                  onTap: () {
                    Navigator.pop(context);
                    APIs.deleteMessage(widget.hash, widget.message);
                  },
                ),
              if (widget.message.type == "text" && isSender) divider,
              OptionItem(
                icon: Icon(
                  Icons.remove_red_eye_sharp,
                  color: Colors.blue.shade600,
                  size: 30,
                ),
                name: isSender
                    ? "Sent at: ${formatMessageSentTime(widget.message.sentAt)}"
                    : "Recived at: ${formatMessageSentTime(widget.message.sentAt)}",
                onTap: () {},
              ),
              if (isSender)
                OptionItem(
                  icon: Icon(
                    Icons.remove_red_eye_sharp,
                    color: Colors.green.shade600,
                    size: 30,
                  ),
                  name:
                      "Read at: ${widget.message.seen ? formatMessageSentTime(widget.message.seenAt!) : "Still Not Seen. LOL"}",
                  onTap: () {},
                )
            ],
          ),
        ),
      ),
    );
  }

  void checkEmojis(String content) {
    var parser = EmojiParser();
    String unemojify = parser.unemojify(content);
    // print("Emoji Code and types: $unemojify");
    int length = content.length;
    if (hasOnlyEmojis(content)) {
      if (length == 2) {
        // One Emoji Case
        hasOnlyOneEmoji = true;
        fontSize = 40;
        if (unemojify.contains(":heart:") ||
            unemojify.contains(":two_hearts:")) {
          // Only in this case we will see if the only emoji is heart.
          isHeartEmoji = true;
          fontSize = 48;
          print("Yes the string contents the heart. $content");
        }
      } else if (length == 4) {
        fontSize = 36;
      } else if (length == 6) {
        fontSize = 30;
      } else {
        fontSize = 24;
      }
    }
  }

  Widget _buildContent(ColorScheme colorScheme, bool isSender) {
    /// Builds the content widget based on the given color scheme and sender information.
    /// Content Widget is used to display the text or image based on the messageType.
    ///
    /// Parameters:
    ///   - colorScheme: The color scheme to use for styling the content.
    ///   - isSender: A boolean indicating whether the content is from the sender.
    ///
    /// Returns:
    ///   - The built content widget.

    final messageContent = widget.message.content;

    // This function will check the emojis status, whether string has only emojis and if yes then
    // how many and accordingly will set the bools to their values and also update the fontsize.
    checkEmojis(messageContent);

    Widget content = Text(
      messageContent,
      textWidthBasis: TextWidthBasis.longestLine,
      style: TextStyle(
        fontSize: fontSize,
        color: isSender
            ? colorScheme.onPrimaryContainer
            : colorScheme.onTertiaryContainer,
      ),
    );

    if (isHeartEmoji) {
      content = Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: content,
        ),
      );
    }

    if (widget.message.type == "image") {
      content = Hero(
        tag: "message_card_image_hero_tag_${widget.message.messageId}",
        transitionOnUserGestures: true,
        child: CachedNetworkImage(
          imageUrl: messageContent,
          placeholder: (context, url) => const Icon(Icons.image),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          imageBuilder: (context, imageProvider) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
          width: 200,
          height: 200,
        ),
      );
    }
    return content;
  }

  Widget _buildOptions(
      ColorScheme colorScheme, bool isSender, Widget content, Size mq) {
    // A function to build options widget based on platform, taking colorScheme, isSender, content, and mq as parameters and returning a Widget.
    // This widget is used to build the options menu button or gesture depending on the platform.

    Widget options = GestureDetector(
      onTap: () {
        if (widget.message.type == "image") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoViewer(
                image: NetworkImage(widget.message.content),
                message: widget.message,
                name: isSender
                    ? "You"
                    : widget.toUser.name.isEmpty
                        ? widget.toUser.userName
                        : widget.toUser.name,
                herotag:
                    "message_card_image_hero_tag_${widget.message.messageId}",
              ),
            ),
          );
        }
      },
      onLongPress: () {
        print("Long press detected");
        _showBottomSheet(mq, isSender);
      },
      child: _buildAllPlatformStack(isSender, mq, colorScheme, content),
    );

    if (kIsWeb) {
      options = MouseRegion(
        onEnter: (event) => setState(() => isArrowButtonActive = true),
        onExit: (event) => setState(() => isArrowButtonActive = false),
        child: options,
      );
    }
    return options;
  }

  Widget _buildOuterContainer(
      ColorScheme colorScheme, bool isSender, Widget options) {
    /**
     * Builds the outer container for the given color scheme, sender, and options.
     *
     * @param colorScheme the color scheme to use for the container
     * @param isSender a boolean indicating whether the message is from the sender
     * @param options the widget to display in the container
     * @return the built outer container widget
     */
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      alignment: isSender ? Alignment.topRight : Alignment.topLeft,
      child: options,
    );
  }

  Widget _buildAllPlatformStack(
      bool isSender, Size mq, ColorScheme colorScheme, Widget content) {
    /// Builds a stack widget that contains a container with a stack of content. Main widget that will put all the widget together for the message card.
    ///
    /// The container has a minimum width of 20% of the screen width and a maximum width of 80% of the screen width.
    /// The container has a border radius of 20 and a color based on the [isSender] parameter.
    /// The container contains a stack of content, including a padding, and a positioned widget at the bottom right with time and seen status.
    /// If [isArrowButtonActive] is true, a positioned widget with an arrow button is added at the top right.
    ///
    /// Parameters:
    /// - `isSender`: a boolean indicating whether the message is sent by the current user.
    /// - `mq`: a `Size` object representing the screen size.
    /// - `colorScheme`: a `ColorScheme` object representing the color scheme.
    /// - `content`: a `Widget` representing the content of the stack.
    ///
    /// Returns:
    /// A `Widget` representing the stack of containers and content.
    return Stack(
      children: [
        Container(
          constraints: BoxConstraints(
              minWidth:
                  (widget.message.editedAt != null) ? 120 : mq.width * 0.3,
              maxWidth: mq.width * 0.8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSender
                ? colorScheme.primaryContainer
                : colorScheme.tertiaryContainer,
          ),
          child: Stack(
            children: [
              Padding(
                padding: (widget.message.type == "image")
                    ? const EdgeInsets.only(
                        top: 5.0, bottom: 20, left: 7.5, right: 7.5)
                    : const EdgeInsets.only(
                        top: 5.0, bottom: 15, left: 8, right: 8),
                child: content,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Row(
                  children: [
                    if (widget.message.editedAt != null)
                      Text(
                        "Edited",
                        style: TextStyle(
                            fontSize: 12,
                            color: isSender
                                ? colorScheme.onPrimaryContainer
                                    .withOpacity(0.7)
                                : colorScheme.onTertiaryContainer
                                    .withOpacity(0.7)),
                      ),
                    const SizedBox(width: 5),
                    Text(
                      extractTimeFromDateTime(widget.message.sentAt),
                      style: TextStyle(
                          fontSize: 12,
                          color: isSender
                              ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                              : colorScheme.onTertiaryContainer
                                  .withOpacity(0.7)),
                    ),
                    if (isSender) ...[
                      const SizedBox(width: 5),
                      if (widget.message.seen == false)
                        const Icon(Icons.done, size: 12),
                      if (widget.message.seen)
                        Icon(
                          Icons.done_all,
                          size: 12,
                          color: Colors.blueAccent.shade700,
                        )
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isArrowButtonActive)
          Positioned(
            top: 0,
            right: 0,
            child: MaterialButton(
              elevation: 0,
              focusElevation: 0,
              onPressed: () {
                _showBottomSheet(mq, isSender);
              },
              shape: const CircleBorder(),
              color: isSender
                  ? colorScheme.primaryContainer
                  : colorScheme.tertiaryContainer,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).iconTheme.color!.withOpacity(0.9),
              ),
            ),
          ),
      ],
    );
  }

  Widget build(BuildContext context) {
    final bool isSender = widget.message.senderId == currentUser!.uid;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    Size mq = MediaQuery.of(context).size;
    // Build content based on message type

    final Widget content = _buildContent(colorScheme, isSender);

    // Build options widget
    final Widget options = _buildOptions(colorScheme, isSender, content, mq);

    // Build outer container
    final Widget outerContainer =
        _buildOuterContainer(colorScheme, isSender, options);
    // print("${widget.message.content} ${widget.message.sentAt.toLocal()}");
    // Return outer container with InkWell for non-web platforms
    return kIsWeb
        ? outerContainer
        : InkWell(
            onLongPress: () {},
            child: outerContainer,
          );
  }
}
