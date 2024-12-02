import 'package:afk/reusable_widget.dart';
import 'package:afk/screens/main_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TapGestureRecognizer _tapRecognizer;

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Image(
              image: const AssetImage('assets/images/WhiteBack.png'),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  logoWidget('assets/images/Icon.png', 250, 250),
                  const SizedBox(height: 70),
                  myTextForm(Icons.email, 'Email Address', false, false,
                      _emailController, () {}),
                  myTextForm(
                    Icons.lock,
                    'Password',
                    _obscureText,
                    true,
                    _passwordController,
                    _togglePasswordVisibility,
                  ),
                  const SizedBox(height: 15),
                  myButton2(context, 'Login', () async {
                    await _loginUser();
                  }),
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.grey),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: const TextStyle(
                            color: Colors.blue,
                          ),
                          recognizer: _tapRecognizer
                            ..onTap = () {
                              Navigator.pushNamed(context, '/SignUp');
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _loginUser() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
);


      User? user = userCredential.user;

      if (user != null) {
        // Store user information in Firestore
        try {
          print('User stored in Firestore successfully.');
        } catch (e) {
          print('Error writing to Firestore: $e');
        }
      }

      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainDashboard()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      String errorMessage = 'Login failed. Please try again.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }

      // Show error message
      _showErrorDialog(errorMessage);
    } catch (e) {
      // Handle other unexpected errors
      _showErrorDialog('An unexpected error occurred. Please try again.');
      print('Unexpected error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
