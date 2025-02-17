import 'package:flutter/material.dart';
import '../models/group.dart';

class GroupWidget extends StatelessWidget {
  final Group group;

  GroupWidget({required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(group.name),
        subtitle: Text("Members: ${group.members.length}"),
      ),
    );
  }
}