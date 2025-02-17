import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:collegelink/services/post_services.dart';
import 'package:collegelink/models/post.dart';
import 'post_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  TextEditingController _searchController = TextEditingController();
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  bool _isSearching = false;

  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return {
          'name': userDoc['name'] ?? 'Unknown',
          'profileImage': userDoc['profileImage'] ?? '',
        };
      } else {
        return {'name': 'Unknown', 'profileImage': ''};
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return {'name': 'Error', 'profileImage': ''};
    }
  }

  void _filterPosts(String query) {
    final filteredPosts = _allPosts.where((post) {
      return post.content.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredPosts = filteredPosts;
    });
  }

  @override
  void initState() {
    super.initState();
    _postService.getPosts().listen((posts) {
      setState(() {
        _allPosts = posts;
        _filteredPosts = posts;
      });
    });

    _searchController.addListener(() {
      _filterPosts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String formatTimestamp(dynamic timestamp) {
    try {
      DateTime postDate;
      if (timestamp is Timestamp) {
        postDate = timestamp.toDate();
      } else if (timestamp is DateTime) {
        postDate = timestamp;
      } else {
        return 'Unknown time';
      }

      DateTime today = DateTime.now();
      if (postDate.year == today.year &&
          postDate.month == today.month &&
          postDate.day == today.day) {
        return DateFormat('HH:mm').format(postDate);
      } else {
        return DateFormat('MM/dd/yyyy').format(postDate);
      }
    } catch (e) {
      print("Error formatting timestamp: $e");
      return 'Error formatting date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_isSearching
            ? Text("Posts",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold))
            : TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search posts...',
            hintStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(Icons.search, color: Colors.white),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                _filterPosts('');
              },
            )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFF58634),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(!_isSearching ? Icons.search : Icons.close,
                color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filterPosts('');
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _filteredPosts.isEmpty
                ? Center(
                child: Text("No posts available",
                    style: TextStyle(fontSize: 16, color: Colors.grey)))
                : ListView.builder(
              itemCount: _filteredPosts.length,
              itemBuilder: (context, index) {
                Post post = _filteredPosts[index];

                return FutureBuilder<Map<String, dynamic>>(
                  future: getUserData(post.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text("Error loading user data",
                          style:
                          TextStyle(fontSize: 14, color: Colors.grey));
                    }

                    final userName = snapshot.data!['name'];
                    final profileImage = snapshot.data!['profileImage'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: profileImage.isNotEmpty
                                    ? NetworkImage(profileImage)
                                    : NetworkImage(
                                    'https://via.placeholder.com/150'),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    formatTimestamp(post.timestamp),
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          if (post.imageUrl != null &&
                              post.imageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(10), // Remove Card
                              child: Image.network(
                                post.imageUrl!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null)
                                    return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress
                                          .expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          loadingProgress
                                              .expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.error,
                                        color: Colors.red, size: 80),
                                  );
                                },
                              ),
                            ),
                          SizedBox(height: 8),
                          Text(
                            post.content,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          SizedBox(height: 10,),
                          Divider()
                        ],
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
        heroTag: "postButton",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white,size: 35,),
        backgroundColor: Color(0xFFF58634),
      ),
    );
  }
}