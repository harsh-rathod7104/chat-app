import 'dart:developer';

import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_room_id.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/pages/chat_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_animation_transition/animations/right_to_left_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:uuid/uuid.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController emailController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatroom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      //Fetch the existing one
      log("Chatroom already exist");
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatroom = existingChatRoom;
    } else {
      //create a new  one
      log("chatroom not created");
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());
      chatroom = newChatRoom;

      log("New chatroom created");
    }
    return chatroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Page"),
      ),
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(hintText: "Enter Email"),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              child: Text("Search"),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: emailController.text)
                    .where('email', isNotEqualTo: widget.userModel.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;

                      return Expanded(
                          child: ListView.builder(
                              itemCount: dataSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> userMap =
                                    dataSnapshot.docs[index].data()
                                        as Map<String, dynamic>;
                                UserModel searcheduser =
                                    UserModel.fromJson(userMap);
                                return ListTile(
                                  onTap: () async {
                                    log(widget.userModel.email.toString());
                                    ChatRoomModel? chatRoomModel =
                                        await getChatRoomModel(searcheduser);

                                    if (chatRoomModel != null) {
                                      Navigator.pop(context);
                                      Navigator.of(context).push(
                                          PageAnimationTransition(
                                              page: ChatRoomScreen(
                                                targetUser: searcheduser,
                                                userModel: widget.userModel,
                                                firebaseUser:
                                                    widget.firebaseUser,
                                                chatRoom: chatRoomModel,
                                              ),
                                              pageAnimationType:
                                                  RightToLeftTransition()));
                                    }
                                  },
                                  title: Text(searcheduser.fullname.toString()),
                                  subtitle: Text(searcheduser.email.toString()),
                                  leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          searcheduser.profilePic!)),
                                  trailing: Icon(Icons.keyboard_arrow_right),
                                );
                              }));
                    } else if (snapshot.hasError) {
                      return Text("An error occured");
                    } else {
                      return Text("No User found!..");
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                })
          ],
        ),
      )),
    );
  }
}
