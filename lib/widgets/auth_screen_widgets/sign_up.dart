import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/widgets/auth_screen_widgets/user_image_picker.dart';
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
    Size mq = MediaQuery.of(context).size;
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
          maxLength: 20,
          enableSuggestions: false,
          onChanged: (newValue) {
            newValue = newValue.trim();
            onUsernameSaved(newValue);
          },
          onSaved: (newValue) {
            newValue = newValue!.trim();
            onUsernameSaved(newValue);
          },
          validator: (newValue) {
            newValue = newValue?.trim();
            if (newValue == null || newValue.isEmpty) {
              return "Bhaiii Please enter the username.";
            }
            if (newValue.contains(" ")) {
              return "Spaces are not allowed bro.";
            }
            if (newValue.length < 6 ||
                !isMatchingWithRegex("^[a-z0-9._]{6,20}", newValue)) {
              showSnackBarWithText(
                  context,
                  "Keep it between 6 and 20 characters long. We don't want a novel for a username, just something catchy!. Characters allowed are: a-z, 0-9, '.', '-'",
                  const Duration(seconds: 5));
              return "";
            }
            return null;
          },
        ),
        SizedBox(height: mq.height * 0.02),
      ],
    );
  }
}
