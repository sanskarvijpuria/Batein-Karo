import 'package:chat_app/functions/helper.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatefulWidget {
  const PhotoViewer({super.key, required this.image, required this.imageURL});
  final ImageProvider image;
  final String imageURL;

  @override
  _PhotoViewerState createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  bool _isShowAppBar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: _isShowAppBar ? true : false,
        actions: [
          if (_isShowAppBar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                onPressed: () async {
                  await downloadImage(context, widget.imageURL);
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
          heroAttributes: const PhotoViewHeroAttributes(
              tag: "image_open", transitionOnUserGestures: true),
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
