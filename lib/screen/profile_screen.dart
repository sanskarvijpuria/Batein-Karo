import 'dart:io';

import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(this.currentUser, {super.key});

  final ChatUser currentUser;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Size mq;
  Map<String, dynamic> userData = {};
  bool isSavingData = false;
  bool _isInitialised = false;
  ImageProvider? _pickedImage;
  XFile? selectedImage;
  String? downloadURL;

  @override
  void initState() {
    super.initState();
  }

  void _pickImage({bool isCamera = true}) async {
    selectedImage = await pickImageUsingImagePicker(isCamera: isCamera);
    if (selectedImage == null) {
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
  }

  void _selectImage() {
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
                _pickImage(isCamera: true);
                Navigator.pop(context);
              },
            ),
            _buildImageButton(
              assetPath: "assets/images/gallery.gif",
              text: "Select From Gallery",
              onPressed: () {
                _pickImage(isCamera: false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void updateUserData(String keyName, String newValue, String snapValue,
      {bool isImage = false}) async {
    if (_isInitialised && userData.containsKey(keyName)) {
      if (userData[keyName].trim() == newValue.trim()) {
        userData.remove(keyName);
        if (isImage) {
          selectedImage = null;
          downloadURL = null;
        }
      } else {
        userData[keyName] = newValue.trim();
      }
    } else if (isImage || newValue.trim() != snapValue) {
      userData[keyName] = newValue.trim();
    }
  }

  void onSubmit() async {
    final form = _formKey.currentState!;

    if (!form.validate()) {
      return;
    }

    if (selectedImage != null) {
      if (downloadURL == null) {
        downloadURL = await APIs.putFiletoFirebaseStorage(selectedImage!,
            "user-Images", widget.currentUser.uid + DateTime.now().toString());
        print(downloadURL);
      }
      updateUserData("user_image", downloadURL!, "", isImage: true);
    }

    form.save();
    if (userData.isEmpty) {
      return;
    }

    setState(() {
      isSavingData = true;
    });

    try {
      print(
          "Logs: Profile Update user data: $userData , ${widget.currentUser.uid}");
      await APIs.updateUserData(userData, widget.currentUser.uid);
      if (context.mounted) {
        showSnackBarWithText(
            context, "Your Data is saved.", const Duration(seconds: 3));
      }
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        isSavingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return FutureBuilder(
        future: APIs.getSelfData(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              (_isInitialised == false)) {
            return const Center(child: CircularProgressIndicator());
          } else {
            _isInitialised = true;
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Some Error occured. Please try again later.",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  elevation: 15,
                  centerTitle: true,
                  title: const Text('Your Glorious Profile'),
                ),
                body: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: mq.height * 0.05,
                            left: mq.width * 0.03,
                            right: mq.width * 0.03),
                        child: Column(
                          children: [
                            _buildProfilePicture(snapshot),
                            SizedBox(height: mq.height * 0.03),
                            // USERNAME
                            _buildUsernameField(snapshot, context),
                            SizedBox(height: mq.height * 0.025),
                            // NAME
                            _buildNameField(snapshot),
                            SizedBox(height: mq.height * 0.025),
                            _buildAboutField(snapshot),
                            SizedBox(height: mq.height * 0.025),
                            _buildEmailField(snapshot),
                            // Save button with funny text
                            SizedBox(height: mq.height * 0.025),
                            isSavingData
                                ? const CircularProgressIndicator()
                                : FloatingActionButton.extended(
                                    onPressed: () {
                                      // Implement your logic to save the username and name
                                      onSubmit();
                                    },
                                    label: const Text('Save My Awesomeness'),
                                    icon: const Icon(Icons.edit),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        });
  }

  Widget _buildProfilePicture(AsyncSnapshot snapshot) {
    return Stack(
      children: [
        CircleAvatar(
          radius: mq.height * 0.12,
          backgroundImage:
              _pickedImage ?? Image.network(snapshot.data.userImage).image,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton.filled(
            onPressed: () {
              _selectImage();
            },
            icon: const Icon(Icons.edit),
          ),
        ),
      ],
    );
  }

// Profile Picture Update Button using BottomSheet
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

  Widget _buildUsernameField(AsyncSnapshot snapshot, BuildContext context) {
    return TextFormField(
      initialValue: snapshot.data.userName,
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      validator: (newValue) {
        newValue = newValue?.trim();
        if (newValue == null ||
            isMatchingWithRegex("/^[a-zA-Z0-9._]{6,20}", newValue)) {
          showSnackBarWithText(
            context,
            "Keep it between 6 and 20 characters long. We don't want a novel for a username, just something catchy!",
            const Duration(seconds: 5),
          );
        }
        return null;
      },
      onSaved: (newValue) {
        const String keyName = "user_name";
        updateUserData(keyName, newValue!, snapshot.data.userName);
      },
      decoration: _buildInputDecoration(
        "Your Username (Change it if you dare)",
        "Channel your inner superhero (No Xs for coolness. Avoid 69 too.)",
        Icons.person,
      ),
    );
  }

  Widget _buildNameField(AsyncSnapshot snapshot) {
    return TextFormField(
      initialValue: snapshot.data.name,
      onSaved: (newValue) {
        const String keyName = "name";
        updateUserData(keyName, newValue!, snapshot.data.name);
      },
      decoration: _buildInputDecoration(
        "Your Real (or Imaginary, we hope not) Name",
        "Your real name, please. Unless you're Batman.",
        CupertinoIcons.person_crop_circle,
      ),
    );
  }

  Widget _buildAboutField(AsyncSnapshot snapshot) {
    return TextFormField(
      initialValue: snapshot.data.about,
      onSaved: (newValue) {
        const String keyName = "about";
        updateUserData(keyName, newValue!, snapshot.data.about);
      },
      decoration: _buildInputDecoration(
        "Life in a few sentences.",
        "\"About you,\" not \"About your cat.\" (Unless your cat is super cool)",
        CupertinoIcons.person_crop_circle,
      ),
    );
  }

  Widget _buildEmailField(AsyncSnapshot snapshot) {
    return TextFormField(
      initialValue: snapshot.data.email,
      readOnly: true,
      decoration: _buildInputDecoration(
        'Your Email Address (For Sending Memes)',
        "No Hint text here, as email will always be there.",
        CupertinoIcons.mail,
        isDisabledField: true,
      ),
      style: TextStyle(color: Colors.grey.shade600),
    );
  }

  InputDecoration _buildInputDecoration(
      String labelText, String hintText, IconData icon,
      {isDisabledField = false}) {
    return InputDecoration(
      hintStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      hintText: hintText,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide:
            BorderSide(color: isDisabledField ? Colors.grey : Colors.blue),
      ),
      icon: Icon(icon),
      labelText: labelText,
    );
  }
}
