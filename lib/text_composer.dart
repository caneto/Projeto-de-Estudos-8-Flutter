import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  TextComposer(this.sendMenssage, {Key? key}) : super(key: key);

  Function({String? text, XFile? imgFile}) sendMenssage;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isComposer = false;

  void _reset() {
    _controller.clear();
    setState(() {
      _isComposer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () async {
              final XFile? img = await _picker.pickImage(source: ImageSource.camera);
              if(img != null) {
                setState(() {
                  widget.sendMenssage(imgFile: img);
                });
              } else return;
            },
            icon: Icon(Icons.photo_camera),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
                  InputDecoration.collapsed(hintText: 'Enviar a mensagem'),
              onChanged: (text) {
                setState(() {
                  _isComposer = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMenssage(text: text);
                _reset();
              },
            ),
          ),
          IconButton(
            onPressed: _isComposer ? () {
              widget.sendMenssage(text: _controller.text);
              _reset();
            } : null,
            icon: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
