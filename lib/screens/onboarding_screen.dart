import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/Logo.png')),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Discover your dream house \nfrom smartphone',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'The No.1 App for searching and finding \nthe most suitable house with you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/Login');
              },
              child: Container(
                width: 320,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xff002871),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Text(
                    "Let's Get Started",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
          ],
        ));
  }
}