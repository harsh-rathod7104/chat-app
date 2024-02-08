import 'dart:developer';
import 'dart:io';

import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const CompleteProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  TextEditingController nameController = TextEditingController();
  File? profilePic;
  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );

    if (croppedImage != null) {
      File image = File(croppedImage.path);
      setState(() {
        profilePic = image;
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Upload Profle Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.folder),
                  title: const Text("Select From Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  title: const Text("Take Selfi"),
                  leading: const Icon(Icons.camera_alt_rounded),
                ),
              ],
            ),
          );
        });
  }

  void checkValidation() {
    String fullname = nameController.text.trim();
    if (fullname == '' || profilePic == null) {
      log("Please fill all the field");
    } else {
      log("uploading data.....");
      uploadData(fullname);
    }
  }

  void uploadData(String fullname) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilePic")
        .child(widget.userModel.uid.toString())
        .putFile(profilePic!);

    TaskSnapshot taskSnapshot = await uploadTask;
    String imgUrl = await taskSnapshot.ref.getDownloadURL();

    widget.userModel.fullname = fullname;
    widget.userModel.profilePic = imgUrl;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.firebaseUser.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      log('data uploaded');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Complete Profile"),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                showPhotoOptions();
              },
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    (profilePic != null) ? FileImage(profilePic!) : null,
                child: (profilePic == null)
                    ? const Icon(
                        Icons.person,
                        size: 60,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: "Full Name"),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              onPressed: () {
                checkValidation();
              },
              color: Theme.of(context).colorScheme.secondary,
              child: const Text("Submit"),
            ),
          ],
        ),
      )),
    );
  }
}
