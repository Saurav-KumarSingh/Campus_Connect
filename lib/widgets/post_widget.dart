import 'package:flutter/material.dart';
import '../models/post.dart';

class PostWidget extends StatelessWidget {
  final Post post;

  PostWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(post.content),
        subtitle: Text(post.timestamp.toString()),
      ),
    );
  }
}