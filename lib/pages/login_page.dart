import 'dart:developer';

import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/pages/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  checkValidation() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      log('Please fill all field!');
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? userCredential;

    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      log(ex.code.toString());
    }

    if (userCredential != null) {
      String uid = userCredential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromJson(userData.data() as Map<String, dynamic>);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                  userModel: userModel, firebaseUser: userCredential!.user!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Chat App",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(hintText: "Email"),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(hintText: "Password"),
                  ),
                  const SizedBox(height: 15),
                  CupertinoButton(
                    onPressed: () {
                      checkValidation();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text("Login"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?",
                style: TextStyle(
                  fontSize: 16,
                )),
            CupertinoButton(
                child: Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.of(context).push(PageAnimationTransition(
                      page: const SignUpPage(),
                      pageAnimationType: RightToLeftTransition()));
                })
          ],
        ),
      ),
    );
  }
}
