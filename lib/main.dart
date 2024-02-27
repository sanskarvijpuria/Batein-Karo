import 'package:chat_app/screen/chat.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'firebase_options.dart';
import 'package:chat_app/screen/auth.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  runApp(MyApp(widgetsBinding: widgetsBinding));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.widgetsBinding});

  final WidgetsBinding widgetsBinding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 47, 5, 153)),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            FlutterNativeSplash.remove();
            if (snapshot.hasData) {
              return const ChatScreen();
            } else {
              return const AuthScreen();
            }
          }
          return Container();
        },
      ),
    );
  }
}
