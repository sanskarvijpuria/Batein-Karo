import 'package:batein_karo/screen/user_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:batein_karo/theme/theme_data.dart';

import 'package:batein_karo/screen/home_screen.dart';
import 'package:batein_karo/screen/auth_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();
// late Size mq;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    print("Debugging");
    // Using Firebase local emulator. Comment below lines if you are not using local emulator.
    await FirebaseAuth.instance.useAuthEmulator('192.168.1.8', 9099);
    await FirebaseStorage.instance.useStorageEmulator('192.168.1.8', 9199);
    FirebaseFirestore.instance.useFirestoreEmulator('192.168.1.8', 8080);
  }
  runApp(MyApp(widgetsBinding: widgetsBinding));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.widgetsBinding});

  final WidgetsBinding widgetsBinding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Batein Karo ',
      theme: customLightTheme,
      navigatorKey: navigatorKey,
      routes: {
        "/home_screen": (context) => const HomeScreen(),
        "/user_chat_screen": (context) {
          return UserChatScreen(null);
        }
      },
      darkTheme: customDarkTheme,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            FlutterNativeSplash.remove();
            if (snapshot.hasData) {
              return const HomeScreen();
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
