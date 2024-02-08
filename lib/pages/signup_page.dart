import 'dart:developer';

import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/pages/complete_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void cheackValidation() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cpassword = cPasswordController.text.trim();

    if (email == "" || password == "" || cpassword == "") {
      print('Please fill all the fields');
    } else if (password != cpassword) {
      print("password do not match");
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      debugPrint(ex.code.toString());
    }

    if (userCredential != null) {
      String uid = userCredential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, fullname: "", profilePic: "");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        log("new user created");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CompleteProfile(
                    userModel: newUser, firebaseUser: userCredential!.user!)));
      });
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
                  TextField(
                    controller: cPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(hintText: "Confirm Password"),
                  ),
                  const SizedBox(height: 15),
                  CupertinoButton(
                    onPressed: () {
                      cheackValidation();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text("Sign Up"),
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
            Text("Already have an account",
                style: TextStyle(
                  fontSize: 16,
                )),
            CupertinoButton(
                child: Text(
                  "Log In",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
  }
}
