import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserPickedImage extends StatefulWidget {
  const UserPickedImage({super.key, required this.onPickImage});

  final void Function(XFile pickedImage) onPickImage;

  @override
  State<UserPickedImage> createState() => _UserPickedImageState();
}

class _UserPickedImageState extends State<UserPickedImage> {
  ImageProvider? _pickedImage;

  void _pickImage({bool isCamera = true}) async {
    XFile? selectedImage;
    if (isCamera) {
      selectedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      selectedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 200,
      );
    }

    if(selectedImage == null){
      return;
    }

    setState(() {
      if (kIsWeb) {
        _pickedImage = Image.network(selectedImage!.path).image;
      } else {
        _pickedImage = FileImage(
          File(selectedImage!.path),
        );
      }
    });

    widget.onPickImage(selectedImage);
  }

  @override
  Widget build(BuildContext context) {
    Widget? circleAvatarChild = _pickedImage== null ? const Icon(Icons.person) : null;

    return Column(
      children: [
        CircleAvatar(
          foregroundImage: _pickedImage,
          child: circleAvatarChild,
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {},
              label: const Text(
                "Take Photo",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.camera),
            ),
            TextButton.icon(
              onPressed: () {
                _pickImage(isCamera: false);
              },
              label: const Text(
                "Select Image From Gallery",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.photo),
            ),
          ],
        )
      ],
    );
  }
}