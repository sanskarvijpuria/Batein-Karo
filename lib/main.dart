import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:chat_app/theme/theme_data.dart';

import 'package:chat_app/screen/home_screen.dart';
import 'package:chat_app/screen/auth_screen.dart';

import 'sample_file.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.useAuthEmulator('192.168.1.9', 9099);
  await FirebaseStorage.instance.useStorageEmulator('192.168.1.9', 9199);
  FirebaseFirestore.instance.useFirestoreEmulator('192.168.1.9', 8080);
  // try {
  //   final sampleFile = SampleFile();
  //   await sampleFile.startHere();
  // } on Exception catch (err) {
  //   print(err.toString());
  // }
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
      // theme: ThemeData().copyWith(
      //   colorScheme: ColorScheme.fromSeed(
      //       seedColor: const Color.fromARGB(255, 47, 5, 153)),
      // ),
      // theme: customLightTheme,
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
