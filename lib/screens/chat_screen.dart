import 'package:flutter/material.dart';
import 'package:collegelink/services/chat_services.dart';
import 'package:collegelink/services/group_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;

  ChatScreen({required this.groupId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final GroupService _groupService = GroupService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentAdmissionNo;

  @override
  void initState() {
    super.initState();
    _loadAdmissionNo();
  }

  // Loads the current user's admission number from Firestore.
  void _loadAdmissionNo() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final admissionNo = await _chatService.getUserAdmissionNo(currentUser.uid);
      setState(() {
        _currentAdmissionNo = admissionNo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    if (_currentAdmissionNo == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Group Chat", style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.deepOrangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<Group>(
      stream: _groupService.getGroup(widget.groupId),
      builder: (context, groupSnapshot) {
        if (!groupSnapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Group Chat", style: TextStyle(color: Colors.white)),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.deepOrangeAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final group = groupSnapshot.data!;
        if (!group.members.contains(_currentAdmissionNo)) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Group Chat", style: TextStyle(color: Colors.white)),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.deepOrangeAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: Center(child: Text("You are not a member of this group.")),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              group.name,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.orangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'leave') {
                    _leaveGroup();
                  } else if (value == 'manage') {
                    _showManageMembersDialog(group);
                  }
                },
                itemBuilder: (context) {
                  List<PopupMenuEntry<String>> items = [];
                  items.add(PopupMenuItem(value: 'leave', child: Text('Leave Group')));
                  if (group.admin == _currentAdmissionNo) {
                    items.add(PopupMenuItem(value: 'manage', child: Text('Manage Members')));
                  }
                  return items;
                },
              ),
              if (group.admin == _currentAdmissionNo)
                IconButton(
                  icon: Icon(Icons.person_add, color: Colors.white),
                  onPressed: _showAddMemberDialog,
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _chatService.getMessages(widget.groupId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("No messages found"));
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final message = snapshot.data![index];
                          final isSender = message['senderAdmissionNo'] == _currentAdmissionNo;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Align(
                              alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSender ? Colors.orange.shade200 : Colors.blueAccent.shade100,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isSender)
                                      Text(
                                        message['senderName'] ?? 'Unknown',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal, color: Colors.brown),
                                      ),
                                    SizedBox(height: 1,),
                                    Text(
                                      message['message'] ?? '',
                                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(color: Colors.orange),
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.orangeAccent),
                      onPressed: () async {
                        if (_messageController.text.trim().isEmpty) return;
                        final messageText = _messageController.text.trim();
                        final senderAdmissionNo = _currentAdmissionNo!;
                        final senderName = await _chatService.getUserNameByAdmissionNo(senderAdmissionNo);

                        // Send the message
                        await _chatService.sendMessage(
                          widget.groupId, // Using groupId as chatId.
                          senderAdmissionNo,
                          messageText,
                          senderName,
                        );

                        // Clear the input box
                        _messageController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMemberDialog() {
    final TextEditingController _newMemberController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Member"),
          content: TextField(
            controller: _newMemberController,
            decoration: InputDecoration(hintText: "Enter Admission No"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",style: TextStyle(color: Colors.deepOrange),),
            ),
            ElevatedButton(
              onPressed: () async {
                final newMemberAdmissionNo = _newMemberController.text.trim();
                if (newMemberAdmissionNo.isNotEmpty) {
                  try {
                    await _groupService.addMemberToGroup(widget.groupId, newMemberAdmissionNo);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Member added successfully")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error adding member: $e")),
                    );
                  }
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _leaveGroup() async {
    try {
      await _groupService.removeMemberFromGroup(widget.groupId, _currentAdmissionNo!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You left the group")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error leaving group: $e")),
      );
    }
  }

  void _showManageMembersDialog(Group group) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Manage Members"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: group.members.length,
              itemBuilder: (context, index) {
                final member = group.members[index];
                return ListTile(
                  title: Text(member),
                  trailing: (member != group.admin)
                      ? IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () async {
                      bool confirmed = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Remove Member"),
                            content: Text("Are you sure you want to remove $member?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text("Remove"),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmed) {
                        try {
                          await _groupService.removeMemberFromGroup(widget.groupId, member);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Member removed successfully")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error removing member: $e")),
                          );
                        }
                      }
                    },
                  )
                      : null,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}