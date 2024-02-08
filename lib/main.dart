import 'dart:io';

import 'package:chatapp/pages/complete_profile.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/pages/login_page.dart';
import 'package:chatapp/pages/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyAJd-Hs4l9IkXqNrNewqD0a9lvkoF7qtmo",
            appId: "1:423610546693:android:f4b2ce890ff6cda1bffa6c",
            messagingSenderId: "423610546693",
            projectId: "chat-app-3b29b",
            storageBucket: "chat-app-3b29b.appspot.com",
          ),
        )
      : await Firebase.initializeApp();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
