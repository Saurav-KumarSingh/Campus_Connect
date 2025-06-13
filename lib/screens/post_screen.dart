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
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 28,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // Image Picker Card
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: const Color(0xFF98BEFD),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.deepPurpleAccent.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: (_image != null || (kIsWeb && _webImage != null))
                              ? (kIsWeb && _webImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.memory(
                                        _webImage!,
                                        width: double.infinity,
                                        height: 220,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        _image!,
                                        width: double.infinity,
                                        height: 220,
                                        fit: BoxFit.cover,
                                      ),
                                    ))
                              : const Icon(Icons.add, size: 48, color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Note Text Field Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF0FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: SizedBox(
                          height: 320,
                          child: TextFormField(
                            controller: _contentController,
                            decoration: const InputDecoration(
                              hintText: 'Write your thoughts here...',
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            expands: true,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Post Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);

                                String? userId = FirebaseAuth.instance.currentUser?.uid;
                                if (userId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("You must be logged in to post")));
                                  setState(() => _isLoading = false);
                                  return;
                                }

                                String? imageUrl = await _uploadImage();

                                Post post = Post(
                                  id: DateTime.now().toString(),
                                  userId: userId,
                                  content: _contentController.text,
                                  timestamp: DateTime.now(),
                                  imageUrl: imageUrl,
                                );

                                await PostService().addPost(post);

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottomNavScreen()),
                                );
                              },
                        icon: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Icon(Icons.arrow_forward, color: Colors.white),
                        label: const Text(
                          "POST",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF944D),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}