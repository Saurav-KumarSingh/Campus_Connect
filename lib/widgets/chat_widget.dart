import 'package:flutter/material.dart';

class ChatWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Chat Message"),
      subtitle: Text("Timestamp"),
    );
  }
}