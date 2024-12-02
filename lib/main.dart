import 'package:afk/firebase_options.dart';
import 'package:afk/screens/main_dashboard.dart';
import 'package:afk/screens/login_screen.dart';
import 'package:afk/screens/onboarding_screen.dart';
import 'package:afk/screens/sign_up_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Property Edge',
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/Login': (context) => const LoginScreen(),
        '/SignUp': (context) => const SignUpScreen(),
        '/MainDashboard' : (context) => const MainDashboard(),
        
      },
    );
  }
}
