import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isLogin = true;
  String email = '';
  String password = '';
  String errorMessage = '';
  bool isLoading = false;
  Color bgColor1 = Colors.blue[900]!;
  Color bgColor2 = Colors.blue[700]!;

  @override
  void initState() {
    super.initState();
    _animateBackground();
  }

  // Background color animation
  void _animateBackground() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        bgColor1 = bgColor1 == Colors.blue[900] ? Colors.blue[800]! : Colors.blue[900]!;
        bgColor2 = bgColor2 == Colors.blue[700] ? Colors.blue[600]! : Colors.blue[700]!;
      });
    }
  }

  // Redirect user to HomeScreen
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  // Handle Authentication (Email/Password)
  Future<void> _authenticate() async {
    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
      }
      _navigateToHome(); // Redirect after login
    } on FirebaseAuthException catch (error) {
      setState(() {
        errorMessage = _getFriendlyErrorMessage(error.code);
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() => isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      _navigateToHome(); // Redirect after Google login
    } catch (error) {
      setState(() => errorMessage = "Google Sign-In failed. Try again.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Convert Firebase error codes to user-friendly messages
  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return "Invalid email format.";
      case 'user-not-found':
        return "No account found with this email.";
      case 'wrong-password':
        return "Incorrect password. Try again.";
      case 'email-already-in-use':
        return "This email is already registered.";
      case 'weak-password':
        return "Password should be at least 6 characters.";
      default:
        return "An unexpected error occurred. Try again.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [bgColor1, bgColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: isLoading
                    ? const SpinKitThreeBounce(color: Colors.white, size: 40.0) // Loading Animation
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Icon
                    const Icon(Icons.lock, size: 80, color: Colors.white),

                    const SizedBox(height: 10),

                    // Auth Mode Title
                    Text(
                      isLogin ? "Welcome Back!" : "Create an Account",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),

                    const SizedBox(height: 20),

                    // Email Input
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(Icons.email, color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) => setState(() => email = val),
                    ),

                    const SizedBox(height: 15),

                    // Password Input
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                      onChanged: (val) => setState(() => password = val),
                    ),

                    const SizedBox(height: 15),

                    // Error Message
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),

                    const SizedBox(height: 20),

                    // Sign In / Sign Up Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _authenticate,
                      child: Text(
                        isLogin ? 'Login' : 'Sign Up',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Switch between Login & Sign Up
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login",
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Google Sign-In Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: _signInWithGoogle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/google-logo.png', height: 24), // Fix asset name
                          const SizedBox(width: 10),
                          const Text(
                            'Sign in with Google',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
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
