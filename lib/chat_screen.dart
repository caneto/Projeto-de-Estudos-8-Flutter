import 'dart:io';

import 'package:chatonlinefirebase/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {



  //final Reference ref = FirebaseStorage.instance
  //    .ref();

  Future<void> _sendMessage({String? text, XFile? imgFile}) async {

    Map<String, dynamic> data = {};

    FirebaseStorage storage = FirebaseStorage.instance;

    if(imgFile != null) {


      final storageRef = FirebaseStorage.instance.ref();

      try {
        final Ref = storageRef.child(imgFile.path);

        await Ref.putFile(
            File(imgFile.path),
            SettableMetadata(customMetadata: {
              'uploaded_by': 'Teste Cap',
              'description': 'Imagem...'
            }));

        String url = await Ref.getDownloadURL();

        if(text != null) data['text'] = text;

        data['imgUrl'] = url;

        FirebaseFirestore.instance.collection("message").add(data);

        // Refresh the UI
        setState(() {});
      } on FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    }

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
      body: Column(
        children: <Widget>[
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
