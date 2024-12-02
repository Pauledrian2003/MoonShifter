import 'package:afk/screens/add_property_screen.dart';
import 'package:flutter/material.dart';
class MyProperty extends StatefulWidget {
  const MyProperty({super.key});

  @override
  State<MyProperty> createState() => _MyPropertyState();
}

class _MyPropertyState extends State<MyProperty> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/MainDashboard');
          },
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddPropertyScreen(),
              ),
            );
          },
          child: const Text('Add Property'),
        ),
      ),
    );
  }
}