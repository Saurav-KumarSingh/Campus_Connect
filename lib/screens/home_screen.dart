import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collegelink/services/post_services.dart';
import 'package:collegelink/models/post.dart';
import 'login_screen.dart';
import 'post_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, Map<String, dynamic>> _userCache = {};
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  bool _isSearching = false;
  bool _isLoading = true;
  String? _currentUserId; // Store current user ID here

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId(); // Fetch current user ID
    _refreshPosts();
    _searchController.addListener(() => _filterPosts(_searchController.text));
  }

  /// Fetch current user ID from Firebase Auth
  Future<void> _fetchCurrentUserId() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.uid; // Set current user ID
      });
    } else {
      print("No user is currently logged in.");
      // Navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  /// Fetch user details from Firestore with caching
  Future<Map<String, dynamic>> getUserData(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    try {
      if (userId.isEmpty) {
        print("Error: userId is empty");
        return {'name': 'Unknown', 'profileImage': ''};
      }

      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = {
          'name': userDoc['name'] ?? 'Unknown',
          'profileImage': userDoc['profileImage'] ?? '',
        };
        _userCache[userId] = userData; // Cache the user data
        return userData;
      } else {
        print("User not found for userId: $userId");
        return {'name': 'Unknown', 'profileImage': ''};
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return {'name': 'Error', 'profileImage': ''};
    }
  }

  /// Filter posts based on search query
  void _filterPosts(String query) {
    setState(() {
      _filteredPosts = _allPosts
          .where((post) => post.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// Refresh posts
  Future<void> _refreshPosts() async {
    setState(() => _isLoading = true);
    _postService.getPosts().listen((posts) {
      setState(() {
        _allPosts = posts;
        _filteredPosts = posts;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Format timestamp
  String formatTimestamp(dynamic timestamp) {
    try {
      DateTime postDate = timestamp is Timestamp ? timestamp.toDate() : timestamp;
      DateTime today = DateTime.now();
      return postDate.year == today.year && postDate.month == today.month && postDate.day == today.day
          ? DateFormat('HH:mm').format(postDate)
          : DateFormat('MM/dd/yyyy').format(postDate);
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
            ? Text(
          "Posts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )
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
            icon: Icon(!_isSearching ? Icons.search : Icons.close, color: Colors.white),
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
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _filteredPosts.isEmpty
            ? Center(
          child: Text(
            "No posts available",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
            : ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 10),
          itemCount: _filteredPosts.length,
          separatorBuilder: (context, index) => Divider(height: 20, thickness: 8),
          itemBuilder: (context, index) {
            final post = _filteredPosts[index];
            return PostItem(
              post: post,
              getUserData: getUserData,
              formatTimestamp: formatTimestamp,
              currentUserId: _currentUserId ?? '', // Pass current user ID
              onLike: () => _postService.likePost(post.id, _currentUserId ?? ''),
              onUnlike: () => _postService.unlikePost(post.id, _currentUserId ?? ''),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "postButton",
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreen())),
        child: Icon(Icons.add, color: Colors.white, size: 35),
        backgroundColor: Color(0xFFF58634),
      ),
    );
  }
}

/// Reusable Post Item Widget
class PostItem extends StatelessWidget {
  final Post post;
  final Future<Map<String, dynamic>> Function(String userId) getUserData;
  final String Function(dynamic timestamp) formatTimestamp;
  final String currentUserId; // Current user ID
  final VoidCallback onLike;
  final VoidCallback onUnlike;

  const PostItem({
    required this.post,
    required this.getUserData,
    required this.formatTimestamp,
    required this.currentUserId,
    required this.onLike,
    required this.onUnlike,
  });

  @override
  Widget build(BuildContext context) {
    final hasLiked = post.likedBy.contains(currentUserId); // Check if the current user has liked the post

    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(post.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Text("Error loading user data", style: TextStyle(fontSize: 14, color: Colors.grey));
        }

        final userName = snapshot.data!['name'];
        final profileImage = snapshot.data!['profileImage'];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Display user profile image or a placeholder
                  if (profileImage.isNotEmpty)
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: NetworkImage(profileImage),
                    )
                  else
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, color: Colors.white), // Placeholder icon
                    ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(formatTimestamp(post.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Icon(Icons.error, color: Colors.red, size: 80),
                      );
                    },
                  ),
                ),
              SizedBox(height: 8),
              Text(post.content, style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black)),
              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: hasLiked ? Colors.red : Colors.grey, // Change color if liked
                    ),
                    onPressed: hasLiked ? onUnlike : onLike, // Call onUnlike if already liked
                  ),
                  Text(post.likes.toString(), style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}