import 'package:collegelink/services/group_services.dart';
import 'package:collegelink/services/profile_services.dart';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/group.dart';

class SearchScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  final GroupService _groupService = GroupService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    String query = _searchController.text;
                    List<UserProfile> users = await _profileService.searchUsers(query);
                    List<Group> groups = await _groupService.searchGroups(query);

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Search Results"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Users:"),
                              ...users.map((user) => ListTile(
                                title: Text(user.name),
                                subtitle: Text(user.email),
                              )),
                              Text("Groups:"),
                              ...groups.map((group) => ListTile(
                                title: Text(group.name),
                                subtitle: Text("Members: ${group.members.length}"),
                              )),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}