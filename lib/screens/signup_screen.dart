import 'package:collegelink/screens/bottomnavbar.dart';
import 'package:collegelink/screens/login_screen.dart';
import 'package:collegelink/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _admissionNoController = TextEditingController();
  final TextEditingController _graduationYearController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      User? user = await AuthService().signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        UserProfile profile = UserProfile(
          id: user.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          graduationYear: _graduationYearController.text.trim(),
          admissionNo: _admissionNoController.text.trim(),
          bio: _bioController.text.trim(),
        );
        await saveUserProfileToFirestore(profile);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-up failed: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40,),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/logo.png'),
                    backgroundColor: null,
                  ),
                  SizedBox(height: 50),
                  _buildTextField(_emailController, "Email", TextInputType.emailAddress),
                  _buildTextField(_passwordController, "Password", TextInputType.text, isPassword: true),
                  _buildTextField(_nameController, "Name", TextInputType.text),
                  _buildTextField(_admissionNoController, "Admission No.", TextInputType.number),
                  _buildTextField(_graduationYearController, "Graduation Year", TextInputType.number),
                  _buildTextField(_bioController, "Bio", TextInputType.text),
                  SizedBox(height: 50),
                  _isLoading
                      ? CircularProgressIndicator()
                      : SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF58634),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Sign Up"),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?'),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                        child: Text("Log In"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, TextInputType keyboardType, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          fillColor: Colors.white12,
          filled: true,
          contentPadding: EdgeInsets.only(left: 30),
          focusedBorder:OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF58634)),
              borderRadius: BorderRadius.circular(50)
          )
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$hintText is required";
          }
          if (hintText == "Email" && !RegExp(r'^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+').hasMatch(value)) {
            return "Enter a valid email";
          }
          if (hintText == "Password" && value.length < 6) {
            return "Password must be at least 6 characters";
          }
          return null;
        },
      ),
    );
  }

  Future<void> saveUserProfileToFirestore(UserProfile profile) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(profile.id);
    await userRef.set({
      'name': profile.name,
      'email': profile.email,
      'graduationYear': profile.graduationYear,
      'admissionNo': profile.admissionNo,
      'bio': profile.bio,
    });
  }
}
