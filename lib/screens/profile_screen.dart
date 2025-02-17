import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegelink/screens/editProfile.dart';
import 'package:collegelink/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collegelink/models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _userId;
  String? _admissionNo;
  String? _userName;
  String? _userBio;
  String? _userEmail;
  String? _graduationYear;
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("User not logged in");
      return;
    }

    _userId = currentUser.uid;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_userId).get();

      if (userDoc.exists) {
        setState(() {
          _admissionNo = userDoc['admissionNo'];
          _userName = userDoc['name'];
          _userBio = userDoc['bio'];
          _userEmail = userDoc['email'];
          _graduationYear = userDoc['graduationYear'];
          _profileImageUrl = userDoc['profileImage']; // Store profile image URL
          _isLoading = false;
        });
      } else {
        print("User data not found in Firestore");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Logout function
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));  // Or your login screen
  }

  // Navigate to EditProfileScreen
  void _editProfile(UserProfile userProfile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userProfile: userProfile),
      ),
    ).then((_) {
      // After coming back from EditProfileScreen, reload the user data
      _fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Image Section (Placeholder as no image is stored)
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : const NetworkImage(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDwmG52pVI5JZfn04j9gdtsd8pAGbqjjLswg&s'),
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _userName ?? 'No Name',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              _userBio ?? 'No bio available',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 25),

            // Admission Number
            ListTile(
              leading: const Icon(Icons.assignment_ind, color: Colors.orange),
              title: Text(_admissionNo ?? 'Admission No not available'),
            ),
            const Divider(),

            // Graduation Year
            ListTile(
              leading: const Icon(Icons.school, color: Colors.orange),
              title: Text(_graduationYear ?? 'Graduation Year not available'),
            ),
            const Divider(),

            // Email
            ListTile(
              leading: const Icon(Icons.email, color: Colors.orange),
              title: Text(_userEmail ?? 'Email not provided'),
            ),
            const Divider(),

            // Edit Profile Button (TextButton)
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                if (_userName != null && _userBio != null) {
                  UserProfile userProfile = UserProfile(
                    id: _userId!,
                    name: _userName!,
                    email: _userEmail!,
                    graduationYear: _graduationYear!,
                    admissionNo: _admissionNo!,
                    bio: _userBio!,
                    profileImage: _profileImageUrl, // Pass the image URL here if available
                  );
                  _editProfile(userProfile);
                }
              },
              child: Row(
                children: [
                  const Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _logout,
              child: Row(
                children: [
                  const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 5,),
                  Icon(Icons.logout,color: Colors.red,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
