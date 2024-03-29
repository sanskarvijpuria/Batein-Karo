import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/widgets/option_items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:http/http.dart' as http;

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message, required this.hash});
  final Message message;
  final String hash;

  @override
  State<MessageCard> createState() => _MessageCardCardState();
}

class _MessageCardCardState extends State<MessageCard> {
  bool isArrowButtonActive = false;

  void _showBottomSheet(Size mq, bool isSender) {
    Widget divider = Divider(
      color: Theme.of(context).dividerColor.withOpacity(0.2),
    );

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
                      try {
                        print("IMAGE URL ${widget.message.content}");
                        if (kIsWeb) {
                          await http
                              .get(Uri.parse(widget.message.content))
                              .then((res) {
                            download(res.bodyBytes,
                                downloadName: "${DateTime.now()}.jpg");
                          });
                        } else {
                          await GallerySaver.saveImage(
                                  "${widget.message.content}.jpg",
                                  albumName: "Batein Karo")
                              .then(
                            (success) {
                              if (success != null) {
                                showSnackBarWithText(
                                    context,
                                    "Image saved to Gallery",
                                    const Duration(seconds: 3));
                              }
                            },
                          );
                        }
                      } on Exception catch (err) {
                        print("Error in Saving Image , $err");
                        // TODO
                      } finally {
                        Navigator.pop(context);
                      }
                    }),
              divider,
              // TODO: Part of version 2
              // if (widget.message.type == "text" && isSender)
              //   OptionItem(
              //     icon: Icon(
              //       Icons.edit,
              //       color: Colors.blue.shade800,
              //       size: 30,
              //     ),
              //     name: "Edit message",
              //     onTap: () {},
              //   ),
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

  @override
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
    Widget content = Text(
      widget.message.content,
      style: TextStyle(
        fontSize: 15,
        color: isSender
            ? colorScheme.onPrimaryContainer
            : colorScheme.onTertiaryContainer,
      ),
    );

    if (widget.message.type == "image") {
      content = CachedNetworkImage(
        imageUrl: widget.message.content,
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
      );
    }
    return content;
  }

  Widget _buildOptions(
      ColorScheme colorScheme, bool isSender, Widget content, Size mq) {
    // A function to build options widget based on platform, taking colorScheme, isSender, content, and mq as parameters and returning a Widget.
    // This widget is used to build the options menu button or gesture depending on the platform.

    Widget options = GestureDetector(
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
              minWidth: mq.width * 0.2, maxWidth: mq.width * 0.8),
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
                        top: 10.0, bottom: 15, left: 15, right: 15),
                child: content,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Row(
                  children: [
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
                        const Icon(Icons.done_all, size: 12)
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
    print("${widget.message.content} ${widget.message.sentAt.toLocal()}");
    // Return outer container with InkWell for non-web platforms
    return kIsWeb
        ? outerContainer
        : InkWell(
            onLongPress: () {},
            child: outerContainer,
          );
  }
}
