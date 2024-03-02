import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/functions/auth_functions.dart';
import 'package:chat_app/functions/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Size mq;
  String _enteredUsername = '';
  String _enteredName = '';
  Map<String, dynamic> userData = {};
  bool isSavingData = false;
  bool _isInitialised = false;

  @override
  void initState() {
    super.initState();
  }

  void onSubmit() async {
    final form = _formKey.currentState!;

    if (!form.validate()) {
      return;
    }

    form.save();
    if (userData.isEmpty) {
      return;
    }

    setState(() {
      isSavingData = true;
    });

    try {
      print("Logs: Profile Update user data: $userData , ${widget.user.uid}");
      await APIs.updateUserData(userData, widget.user.uid);
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
        future: APIs.getUserData(widget.user.uid),
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
                  elevation: 21,
                  title: const Center(child: Text('Your Glorious Profile')),
                ),
                body: Form(
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
                          SizedBox(height: mq.height * 0.025),
                          // USERNAME
                          _buildUsernameField(snapshot, context),
                          SizedBox(height: mq.height * 0.02),
                          // NAME
                          _buildNameField(snapshot),
                          SizedBox(height: mq.height * 0.02),
                          _buildEmailField(snapshot),
                          // Save button with funny text
                          SizedBox(height: mq.height * 0.025),
                          isSavingData
                              ? const CircularProgressIndicator()
                              : FloatingActionButton.extended(
                                  onPressed: () {
                                    // Implement your logic to save the username and name
                                    print('Saving your username and name...');
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
          backgroundImage: Image.network(snapshot.data?["user_image"]).image,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton.filled(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField(AsyncSnapshot snapshot, BuildContext context) {
    return TextFormField(
      initialValue: snapshot.data?["user_name"],
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
        print(newValue);
        const String keyName = "user_name";
        if (_isInitialised && userData.containsKey(keyName)) {
          if (userData[keyName] == newValue!.trim()) {
            userData.remove(keyName);
          }
        } else {
          if (newValue!.trim() != snapshot.data?[keyName]) {
            userData[keyName] = newValue.trim();
          }
        }
      },
      decoration: _buildInputDecoration(
        "Your Username (Change it if you dare)",
        Icons.person,
      ),
    );
  }

  Widget _buildNameField(AsyncSnapshot snapshot) {
    return TextFormField(
      initialValue: snapshot.data?["name"],
      onSaved: (newValue) {
        const String keyName = "name";
        if (_isInitialised && userData.containsKey(keyName)) {
          if (userData[keyName] == newValue!.trim()) {
            userData.remove(keyName);
          }else{
            userData[keyName] = newValue.trim();
          }
        } else if (newValue!.trim() != snapshot.data?[keyName]) {
          userData[keyName] = newValue.trim();
        }
      },
      decoration: _buildInputDecoration(
        "Your Real (or Imaginary) Name",
        CupertinoIcons.person_crop_circle,
      ),
    );
  }

  Widget _buildEmailField(AsyncSnapshot snapshot) {
    return TextFormField(
      initialValue: snapshot.data?["email"],
      readOnly: true,
      decoration: _buildInputDecoration(
        'Your Email Address (For Sending Memes)',
        CupertinoIcons.mail,
        isDisabledField: true,
      ),
      style: TextStyle(color: Colors.grey.shade600),
    );
  }

  InputDecoration _buildInputDecoration(String labelText, IconData icon,
      {isDisabledField = false}) {
    return InputDecoration(
      hintText: labelText,
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
