import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'home_screen.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _user;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isGoogleUser = false;
  bool _isSaving = false;
  String _profileImageUrl = "";
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _isGoogleUser = _user?.providerData.any((info) => info.providerId == "google.com") ?? false;

    if (_user != null) {
      _fetchUserData();
    }
  }

  // Fetch user details from Firestore
  Future<void> _fetchUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection("users").doc(_user!.uid).get();

    if (userDoc.exists) {
      setState(() {
        _nameController.text = userDoc["fullName"] ?? "";
        _phoneController.text = userDoc["phoneNumber"] ?? "";
        _profileImageUrl = userDoc["profileImage"] ?? "";
      });
    }
  }

  // Pick Image from Gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadProfileImage();
    }
  }

  // Upload Profile Image to Firebase Storage
  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;

    String fileName = "profile_${_user!.uid}.jpg";
    Reference ref = _storage.ref().child("profile_images").child(fileName);
    UploadTask uploadTask = ref.putFile(_imageFile!);

    await uploadTask.whenComplete(() async {
      String imageUrl = await ref.getDownloadURL();
      await _firestore.collection("users").doc(_user!.uid).update({"profileImage": imageUrl});
      setState(() {
        _profileImageUrl = imageUrl;
      });
    });
  }

  // Save Profile Changes
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      // Update Firebase Auth Profile
      await _user?.updateDisplayName(_nameController.text);

      // Update Firestore User Data
      await _firestore.collection("users").doc(_user!.uid).update({
        "fullName": _nameController.text,
        "phoneNumber": _phoneController.text,
      });

      setState(() {
        _user = _auth.currentUser;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Profile updated successfully!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to update profile."),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Change Password
  Future<void> _changePassword() async {
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Password must be at least 6 characters."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      await _user?.updatePassword(_passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Password updated successfully!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to update password."),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Sign Out
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Your Huduma App Account", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                          : const AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                    const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name Field
            _buildTextField("Full Name", _nameController, Icons.person, !_isGoogleUser),

            const SizedBox(height: 15),

            // Email (Read-only)
            _buildTextField("Email", TextEditingController(text: _user?.email ?? ""), Icons.email, false),

            const SizedBox(height: 15),

            // Phone Number
            _buildTextField("Phone Number", _phoneController, Icons.phone, true),

            const SizedBox(height: 15),

            // Change Password (Only for Email users)
            if (!_isGoogleUser)
              _buildTextField("New Password", _passwordController, Icons.lock, true, obscureText: true),

            const SizedBox(height: 20),

            // Save Profile Button
            _isSaving
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Center(
                child: Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),

            const SizedBox(height: 15),

            // Change Password Button
            if (!_isGoogleUser)
              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Center(
                  child: Text("Change Password", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),

            const SizedBox(height: 15),

            // Sign Out Button
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Center(
                child: Text("Sign Out", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool editable, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      readOnly: !editable,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
