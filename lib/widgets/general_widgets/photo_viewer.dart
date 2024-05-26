import 'package:batein_karo/functions/helper.dart';
import 'package:batein_karo/models/messages.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatefulWidget {
  PhotoViewer(
      {super.key,
      required this.image,
      required this.name,
      this.message,
      this.profileDialog = false,
      this.herotag =""
      });
  final ImageProvider image;
  Message? message;
  String name;
  bool profileDialog;
  String herotag;

  @override
  PhotoViewerState createState() => PhotoViewerState();
}

class PhotoViewerState extends State<PhotoViewer> {
  bool _isShowAppBar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent.withOpacity(0.4),
        automaticallyImplyLeading: _isShowAppBar ? true : false,
        title: _isShowAppBar
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w500
                      )),
                  if (widget.profileDialog == false)
                    Text(formatMessageSentTime(widget.message!.sentAt),
                        style: Theme.of(context).textTheme.titleSmall),
                ],
              )
            : null,
        actions: [
          if (widget.profileDialog == false && _isShowAppBar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                onPressed: () async {
                  await downloadImage(context, widget.message!.content);
                },
                icon: const Icon(Icons.download),
              ),
            )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isShowAppBar = !_isShowAppBar;
          });
        },
        child: PhotoView(
          imageProvider: widget.image,
          customSize: Size(MediaQuery.sizeOf(context).width * 0.8,
              MediaQuery.sizeOf(context).height * 0.8),
          backgroundDecoration:
              BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
          heroAttributes: PhotoViewHeroAttributes(
              tag: widget.herotag, transitionOnUserGestures: true),
          loadingBuilder: (context, event) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
