import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/main.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/functions/auth_functions.dart';
import 'package:chat_app/widgets/auth_screen_widgets/sign_up.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _enteredEmail = '';
  String _enteredPassword = '';
  String _enteredUsername = '';
  XFile? _selectedImage;
  bool _isAuthenticating = false;
  double opacityLevel = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Durations.extralong4, () {
      setState(() => opacityLevel = opacityLevel == 1 ? 0.0 : 1.0);
    });
  }

  void onPickImage(XFile? pickedImage) {
    _selectedImage = pickedImage;
  }

  void onSubmit() async {
    final AuthFunctions authFunctions = AuthFunctions(context);
    final isValid = _formKey.currentState!.validate();
    if (!_isLogin && _selectedImage == null) {
      showSnackBarWithText(
        context,
        "Please take an image or select from the gallery",
        const Duration(seconds: 3),
      );
      return;
    }

    if (isValid) {
      if (!_isLogin) {
        bool isUsernameExists =
            await APIs.checkUsernameExists(_enteredUsername);
        if (isUsernameExists) {
          showSnackBarWithText(
            navigatorKey.currentContext!,
            "Username already taken. Please try with different username",
            const Duration(seconds: 3),
          );
          return;
        }
      }
      _formKey.currentState!.save();
      setState(() {
        _isAuthenticating = !_isAuthenticating;
      });
      try {
        await authFunctions.authenticateUser(
            _isLogin, _enteredEmail, _enteredPassword);
        if (!_isLogin) {
          final String downloadURL = await authFunctions
              .putProfilePicturetoFirebaseStorage(_selectedImage!);
          await authFunctions.saveDataToFirestore(
              downloadURL, _enteredEmail, _enteredUsername);
          await authFunctions.createRecentMessage();
          await authFunctions.addToUsername(_enteredUsername);
        }
      } on Exception {
        setState(() {
          _isAuthenticating = !_isAuthenticating;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    print(mq);

    if (_isLogin) {
      // Reason to add this here.
      // When user select the image during signup flow and then click on "I have an account button." then user will be reverted back to
      // email screen. But this variable now hold the values even though we are in login flow. Now if user go back to sign up follow
      // and without selecting image and entering any date then they not be shown image as image is already initalised. Hence this.
      _selectedImage = null;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: mq.width * 0.5,
                height: mq.height * 0.2,
                child: AnimatedOpacity(
                  opacity: opacityLevel,
                  duration: const Duration(seconds: 3),
                  child: Image.asset('assets/images/chat.png'),
                ),
              ),
              AnimatedOpacity(
                opacity: opacityLevel,
                duration: const Duration(seconds: 2),
                child: Text(
                  "Hey Guys!!! \n Welcome to the Batein Karo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.headlineSmall!.fontSize,
                      color: Theme.of(context).colorScheme.onSecondary),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            // This is just for username and OnpicImage and if in future if we added more elements then we can
                            // create a seprate widget tree.
                            SignUp(
                                onPickImage: onPickImage,
                                onUsernameSaved: (newValue) {
                                  _enteredUsername = newValue;
                                }),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Email Address",
                            ),
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            onSaved: (newValue) {
                              _enteredEmail = newValue!;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !isEmailValid(value)) {
                                return "Please enter a valid email address";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: mq.height * 0.02),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Password",
                            ),
                            obscureText: true,
                            onSaved: (newValue) {
                              _enteredPassword = newValue!;
                            },
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return "Please enter a valid password at least 6 characters";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: mq.height * 0.02),
                          _isAuthenticating
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: onSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  child: Text(
                                    _isLogin ? "Login" : "Create an Account",
                                  ),
                                ),
                          SizedBox(height: mq.height * 0.01),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? "Create new Account"
                                  : "I already have an Account.",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
