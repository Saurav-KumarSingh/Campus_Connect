import 'package:collegelink/services/group_services.dart';
import 'package:collegelink/services/chat_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import '../models/group.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final GroupService _groupService = GroupService();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Communities", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFF58634),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: StreamBuilder<List<Group>>(
              stream: _groupService.getGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No groups found"));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Group group = snapshot.data![index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFFFFFF).withOpacity(0.8),
                              Color(0xFFFFFFFF).withOpacity(0.4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text(
                              group.name[0].toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color(0xFFF58634),
                              ),
                            ),
                          ),
                          title: Text(
                            group.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.orange,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(Icons.people, size: 20, color: Colors.grey),
                              SizedBox(width: 6),
                              Text(
                                "${group.members.length} Members",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  groupId: group.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showGroupNameInput,
        child: Icon(Icons.add, color: Colors.white, size: 35),
        backgroundColor: Color(0xFFF58634),
      ),
    );
  }

  // Displays a dialog to input a new group name.
  void _showGroupNameInput() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Create New Group"),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(

                border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                fillColor: Colors.white12,
                filled: true,
                contentPadding: EdgeInsets.only(left: 30),
                focusedBorder:OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFF58634)),
                    borderRadius: BorderRadius.circular(50)
                )
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel",style: TextStyle(color: Color(0xFFF58634)),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Create"),
              onPressed: () {
                Navigator.of(context).pop();
                _createGroup();
              },
            ),
          ],
        );
      },
    );
  }

  // Creates a new group using the current user's admission number.
  Future<void> _createGroup() async {
    String groupName = _nameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid group name")),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in")),
        );
        return;
      }
      // Look up the current user's admission number.
      final admissionNo = await _chatService.getUserAdmissionNo(currentUser.uid);
      Group group = Group(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: groupName,
        members: [admissionNo],
        admin: admissionNo,
      );
      await _groupService.createGroup(group);
      _nameController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating group: $e")),
      );
    }
    setState(() => _isLoading = false);
  }
}