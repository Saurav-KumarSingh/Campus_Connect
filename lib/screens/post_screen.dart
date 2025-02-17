import 'dart:typed_data'; // For Uint8List
import 'package:collegelink/screens/bottomnavbar.dart';
import 'package:collegelink/services/post_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File (mobile)
import '../models/post.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _image; // Variable to store picked image (mobile)
  Uint8List? _webImage; // Variable to store image bytes (web)
  bool _isLoading = false; // Loading state for posting

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        setState(() {
          pickedFile.readAsBytes().then((bytes) {
            _webImage = bytes; // Read bytes for web
          });
        });
      } else {
        setState(() {
          _image = File(pickedFile.path); // Use File for mobile
        });
      }
    }
  }

  // Function to upload image to Firebase Storage and get the URL
  Future<String?> _uploadImage() async {
    if (_image == null && _webImage == null) return null;

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('posts/$fileName');

      if (kIsWeb && _webImage != null) {
        // Upload bytes for web
        await storageReference.putData(_webImage!);
      } else if (_image != null) {
        // Upload file for mobile
        await storageReference.putFile(_image!);
      }

      // Get the image URL
      String imageUrl = await storageReference.getDownloadURL();
      print("Uploaded image URL: $imageUrl"); // Print the image URL
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFF58634),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 30),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      hintText: 'Write your post here...',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                    ),
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Card(
                elevation: 5,
                color: Color(0xFFF58634),
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.add_a_photo),
                  label: Text("Pick Image",style: TextStyle(color: Color(0xFFF58634)),),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (kIsWeb && _webImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      _webImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else if (_image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    'No image selected.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading
            ? null
            : () async {
          setState(() => _isLoading = true);

          // Get the current user ID
          String? userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You must be logged in to post")));
            setState(() => _isLoading = false);
            return;
          }

          // Upload image and get the URL
          String? imageUrl = await _uploadImage();
          print("Post Image URL: $imageUrl"); // Print the image URL when creating a post

          // Create the post
          Post post = Post(
            id: DateTime.now().toString(),
            userId: userId,
            content: _contentController.text,
            timestamp: DateTime.now(),
            imageUrl: imageUrl,
          );

          // Save the post to Firestore
          await PostService().addPost(post);

          // Navigate back
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavScreen()),
          );
        },
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Icon(Icons.post_add, color: Colors.white, size: 35),
        backgroundColor: Color(0xFFF58634),
      ),
    );
  }
}