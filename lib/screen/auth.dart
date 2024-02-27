import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:chat_app/functions/helper.dart';
import 'package:chat_app/functions/auth_functions.dart';

import 'package:chat_app/screen/chat.dart';
import 'package:chat_app/widgets/user_image_picker.dart';

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
      _formKey.currentState!.save();
      await authFunctions.authenticateUser(
          _isLogin, _enteredEmail, _enteredPassword);
      final String downloadURL =
          await authFunctions.putFiletoFirebaseStorage(_selectedImage!);
      await authFunctions.saveDataToFirestore(
          downloadURL, _enteredEmail, _enteredUsername);

      
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLogin) {
      // Reason to add this here.
      // When user select the image during signup flow and then click on "I have an accout button." then user will be reverted back to
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
                width: 200,
                child: Image.asset('images/chat.png'),
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
                            UserPickedImage(onPickImage: onPickImage),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Username",
                              ),
                              autocorrect: false,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.none,
                              enableSuggestions: false,
                              onSaved: (newValue) {
                                _enteredUsername = newValue!;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 6) {
                                  return "Please enter a valid username of with minimum length of 6 characters.";
                                }
                                return null;
                              },
                            ),
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
                          const SizedBox(height: 12),
                          ElevatedButton(
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
                          const SizedBox(
                            height: 5,
                          ),
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
