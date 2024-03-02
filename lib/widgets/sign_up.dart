import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatelessWidget {
  const SignUp({
    super.key,
    required this.onPickImage,
    required this.onUsernameSaved,
  });

  final void Function(XFile pickedImage) onPickImage;
  final Function(String) onUsernameSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserPickedImage(onPickImage: onPickImage),
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Username",
          ),
          autocorrect: false,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          onSaved: (newValue) {
            onUsernameSaved(newValue!);
          },
          validator: (newValue) {
            newValue = newValue?.trim();
            if (newValue == null ||
                isMatchingWithRegex("/^[a-zA-Z0-9._]{6,20}", newValue)) {
              showSnackBarWithText(
                  context,
                  "Keep it between 6 and 20 characters long. We don't want a novel for a username, just something catchy!",
                  const Duration(seconds: 5));
            }
            return null;
          },
        ),
      ],
    );
  }
}
