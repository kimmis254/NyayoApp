import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_profile_screen.dart';
import 'edit_profile_screen.dart';
import 'home_screen.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isSignedIn = true;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _isSignedIn = _user != null;
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    setState(() {
      _isSignedIn = false;
      _user = null;
    });
  }

  void _navigateToCreateProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateProfileScreen()));
  }

  void _navigateToEditProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
  }

  void _navigateToAuthScreen() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen()));
  }

  void _goToHomeScreen() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goToHomeScreen();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.blue[900],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Profile", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goToHomeScreen,
          ),
        ),
        body: _user != null
            ? StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection("users").doc(_user!.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              var userData = snapshot.data!;
              String fullName = userData["fullName"] ?? "Create Profile";
              String email = userData["email"] ?? "Not Available";
              String profileImage = userData["profileImage"] ?? "assets/default_profile.png";

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _navigateToEditProfile,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: profileImage.startsWith("http")
                                ? NetworkImage(profileImage)
                                : AssetImage(profileImage) as ImageProvider,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: fullName == "Create Profile" ? _navigateToCreateProfile : null,
                                child: Text(
                                  fullName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    decoration: fullName == "Create Profile"
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              Text(email, style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                        const Icon(Icons.person, color: Colors.white, size: 30),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildProfileOption(Icons.history, "Order History"),
                        _buildProfileOption(Icons.favorite, "Favorites"),
                        _buildProfileOption(Icons.settings, "Settings"),
                        _buildProfileOption(Icons.help, "Help & Support"),
                        _buildProfileOption(Icons.lock, "Privacy Policy"),
                        _buildProfileOption(Icons.star, "Reviews"),
                        _buildProfileOption(Icons.info, "About"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: _isSignedIn ? _signOut : _navigateToAuthScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSignedIn ? Colors.red : Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Center(
                        child: Text(
                          _isSignedIn ? "Sign Out" : "Sign In",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            })
            : Center(
          child: ElevatedButton(
            onPressed: _navigateToAuthScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[900]),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[900])),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      ),
    );
  }
}
