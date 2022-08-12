import 'dart:io';

import 'package:chatonlinefirebase/chat_message.dart';
import 'package:chatonlinefirebase/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  Future<User> _getUser() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleSignInAuthentication = await googleSignInAccount?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken,
      );

      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = authResult.user;

      return user!;
    } catch (error) {
      return null!;
    }
  }

  //final Reference ref = FirebaseStorage.instance
  //    .ref();

  Future<void> _sendMessage({String? text, XFile? imgFile}) async {

    final User? user = await _getUser();

    if(user == null) {
      _globalKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Não foi possivel fazer o login. Tente novamente!"),
          backgroundColor: Colors.red,
        )
      );
    }

    Map<String, dynamic> data = {
      'uId': user?.uid,
      'senderUser': user?.displayName,
      'senderPhotoUrl': user?.photoURL
    };

    //FirebaseStorage storage = FirebaseStorage.instance;

    if(imgFile != null) {
      final storageRef = FirebaseStorage.instance.ref();

      final ref = storageRef.child(imgFile.path);

      try {

        await ref.putFile(
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

      String url = await ref.getDownloadURL();

      data['imgUrl'] = url;
   }

   if(text != null) data['text'] = text;

   FirebaseFirestore.instance.collection("message").add(data);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
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
                          return ChatMessage(documents[index].data());
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
