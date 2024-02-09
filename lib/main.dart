import 'dart:io';

import 'package:chatapp/models/firebase_helper.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

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
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelId(currentUser.uid);
    if (thisUserModel != null) {
      runApp(
          MainAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    }
  } else {
    runApp(const MainApp());
  }
}

//Not logged in
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

class MainAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MainAppLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home: HomePage(
        userModel: userModel,
        firebaseUser: firebaseUser,
      ),
    );
  }
}
