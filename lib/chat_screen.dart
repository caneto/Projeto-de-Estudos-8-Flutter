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
      if(imgFile != null) {
        try {
          final Ref = storageRef.child(imgFile.path);

          await Ref.putFile(
              File(imgFile.path),
              SettableMetadata(customMetadata: {
                'uploaded_by': 'Teste Cap',
                'description': 'Imagem...'
              }));
            // Refresh the UI
            setState(() {});
          } on FirebaseException catch (error) {
            if (kDebugMode) {
              print(error);
            }
          }

          String url = await Ref.getDownloadURL();

          data['imgUrl'] = url;
        }

        if(text != null) data['text'] = text;

        FirebaseFirestore.instance.collection("message").add(data);
    }
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
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("message").snapshots(),
                builder: (context, snapshot) {
                  switch(snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<DocumentSnapshot> documents = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(documents[index].data().toString()),
                          )
                        }
                      );
                  }
                },
              )
          ),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
