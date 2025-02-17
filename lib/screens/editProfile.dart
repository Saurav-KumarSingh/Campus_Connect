import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegelink/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For working with File

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileScreen({super.key, required this.userProfile});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  String? _userId;
  File? _profileImage;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _admissionNoController = TextEditingController();
  final TextEditingController _graduationYearController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize fields with current user data passed from ProfileScreen
    _userId = widget.userProfile.id;
    _nameController.text = widget.userProfile.name;
    _bioController.text = widget.userProfile.bio;
    _admissionNoController.text = widget.userProfile.admissionNo;
    _graduationYearController.text = widget.userProfile.graduationYear;

    // Initialize profile image if available
    if (widget.userProfile.profileImage != null) {
      setState(() {
        _profileImage = null; // Initialize to null so it shows the URL when image is not picked yet
      });
    }
  }

  // Pick image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage() async {
    if (_profileImage == null) return widget.userProfile.profileImage;

    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('profile_pictures/$fileName');

      UploadTask uploadTask = ref.putFile(_profileImage!);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Save updated profile data to Firestore
  Future<void> _saveProfile() async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
    });

    String? imageUrl = await _uploadImage();

    try {
      await _firestore.collection('users').doc(_userId).update({
        'name': _nameController.text,
        'bio': _bioController.text,
        'admissionNo': _admissionNoController.text,
        'graduationYear': _graduationYearController.text,
        if (imageUrl != null) 'profileImage': imageUrl, // Save image URL if available
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green));
      Navigator.pop(context);  // Close the screen and return to ProfileScreen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!) // Show selected image
                      : widget.userProfile.profileImage != null
                      ? NetworkImage(widget.userProfile.profileImage!) // Show existing image
                      : const NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDwmG52pVI5JZfn04j9gdtsd8pAGbqjjLswg&s') as ImageProvider,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name Field
            Text(
              'Name:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),

            // Bio Field
            Text(
              'Bio:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                hintText: 'Enter your bio',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),

            // Admission No Field
            Text(
              'Admission No:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _admissionNoController,
              decoration: InputDecoration(
                hintText: 'Enter your admission number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),

            // Graduation Year Field
            Text(
              'Graduation Year:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _graduationYearController,
              decoration: InputDecoration(
                hintText: 'Enter your graduation year',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF58634),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Save Changes",style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
