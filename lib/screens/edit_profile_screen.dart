import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isGoogleUser = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _isGoogleUser = _user?.providerData.any((info) => info.providerId == "google.com") ?? false;

    if (_user != null) {
      _nameController.text = _user!.displayName ?? "";
      _phoneController.text = _user!.phoneNumber ?? "";
    }
  }

  // Save Profile Changes
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      await _user?.updateDisplayName(_nameController.text);
      await _user?.updatePhoneNumber(_phoneController.text as PhoneAuthCredential);

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
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _user?.photoURL != null
                    ? NetworkImage(_user!.photoURL!)
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
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

  // Helper function to create text fields
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
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
