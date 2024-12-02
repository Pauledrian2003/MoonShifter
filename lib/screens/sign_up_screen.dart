import 'package:afk/reusable_widget.dart';
import 'package:afk/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _obscureText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 11) {
      return 'Phone number must be exactly 11 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number can only contain digits';
    }
    return null;
  }

  String _formatPhoneNumber(String phone) {
    if (phone.length == 11) {
      return '${phone.substring(0, 4)}-${phone.substring(4, 8)}-${phone.substring(8)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                  logoWidget('assets/images/Icon.png', 125, 125),
                  const SizedBox(height: 50),
                  myTextForm(Icons.person, 'FullName', false, false,
                      _nameController, () {}),
                  myTextForm(Icons.email, 'Email Address', false, false,
                      _emailController, () {}),
                  myTextForm(Icons.location_on, 'Address', false, false,
                      _addressController, () {}),
                  myTextForm(
                    Icons.phone,
                    'Phone Number',
                    false,
                    false,
                    _phoneController,
                    () {},
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                    validator: _validatePhone,
                  ),
                  myTextForm(
                    Icons.lock,
                    'Password',
                    _obscureText,
                    true,
                    _passwordController,
                    _togglePasswordVisibility,
                  ),
                  const SizedBox(height: 15),
                  myButton2(context, 'Sign Up', () async {
                    await _signUpUser();
                  }),
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.grey),
                      children: [
                        const TextSpan(text: "Already have an account? "),
                        TextSpan(
                          text: 'Login',
                          style: const TextStyle(
                            color: Colors.blue,
                          ),
                          recognizer: _tapRecognizer
                            ..onTap = () {
                              Navigator.pushNamed(context, '/Login');
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

  Future<void> _signUpUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String address = _addressController.text.trim();
    String phone = _phoneController.text.trim();
    String formattedPhone = _formatPhoneNumber(phone);

    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        address.isEmpty ||
        phone.isEmpty) {
      _showErrorDialog('Please fill in all the fields.');
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'address': address,
          'phone': formattedPhone,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isActive': true,
          'profileComplete': true,
          'role': 'user',
          'profile': {
            'fullName': name,
            'email': email,
            'address': address,
            'phoneNumber': formattedPhone,
            'lastUpdated': FieldValue.serverTimestamp(),
          }
        });

        print('User successfully created with profile data in Firestore.');
        _showSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Sign-up failed. Please try again.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password should be at least 6 characters.';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('An unexpected error occurred. Please try again.');
      print('Error: $e');
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap OK to dismiss
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: const Text(
            'Account created successfully! Please login to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              // Navigate to login screen and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
