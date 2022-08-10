import 'package:chatonlinefirebase/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  void _sendMessage(String text) {
    FirebaseFirestore.instance.collection("message").add({
      'text':text
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Usuario"),
        elevation: 0,
      ),
      body: TextComposer(_sendMessage),
    );
  }
}
