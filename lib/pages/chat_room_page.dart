import 'package:chatapp/models/chat_room_id.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomScreen(
      {super.key,
      required this.targetUser,
      required this.chatRoom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                NetworkImage(widget.targetUser.profilePic.toString()),
          ),
          SizedBox(width: 10),
          Text(widget.targetUser.fullname.toString()),
        ]),
      ),
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(),
            ),
            Container(
              color: Colors.grey.shade200,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter a message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.send),
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
