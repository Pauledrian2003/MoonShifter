import 'package:afk/screens/message_screen.dart';
import 'package:afk/screens/my_property.dart';
import 'package:afk/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  // List of pages to show based on bottom nav selection
  final List<Widget> _pages = [
    const HomePage(),
    const MessageScreen(),
    const MyProperty(),
    const ProfileScreen(),
  ];

  // Add navigation handling method
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // You can add additional navigation logic here if needed
    switch (index) {
      case 0:
        // Already handled by _pages
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MessageScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyProperty()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Updated to use new navigation method
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.house),
            label: 'My Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Example of HomePage widget with image loading
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          // Firestore Stream Builder
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('properties')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No properties found'));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  // Updated image handling with better base64 support
                  Widget imageWidget;
                  if (data['imageUrl'] != null &&
                      data['imageUrl'].toString().isNotEmpty) {
                    // Handle network image URL
                    imageWidget = Image.network(
                      data['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error_outline,
                              size: 50, color: Colors.grey),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    );
                  } else if (data['imageBase64'] != null &&
                      data['imageBase64'].toString().isNotEmpty) {
                    // Handle base64 encoded image
                    try {
                      final String base64String =
                          data['imageBase64'].toString().trim();
                      print('Found base64 image data of length: ${base64String.length}');
                      // Remove data:image/jpeg;base64, prefix if it exists
                      final String cleanBase64 = base64String.replaceAll(
                          RegExp(r'data:image/[^;]+;base64,'), '');

                      final Uint8List bytes = base64Decode(cleanBase64);
                      imageWidget = Image.memory(
                        bytes,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading base64 image: $error');
                          return const Center(
                            child: Icon(Icons.error_outline,
                                size: 50, color: Colors.grey),
                          );
                        },
                      );
                    } catch (e) {
                      print('Base64 decode error: $e');
                        imageWidget = const Center(
                        child: Icon(Icons.error_outline,
                            size: 50, color: Colors.grey),
                      );
                    }
                  } else {
                    // No image available
                    imageWidget = const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Agent info
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person),
                          ),
                          title: Text(data['name']),
                          subtitle: Text(data['location']),
                          trailing: TextButton(
                            onPressed: () {},
                            child: const Text('Phone'),
                          ),
                        ),
                        // Updated Property image container
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageWidget,
                          ),
                        ),
                        // Property details
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    data['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${data['price']}/month',
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('${data['beds']} beds • '),
                                  Text('${data['baths']} baths • '),
                                  Text('${data['sqft']} sqft'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Property Details'),
                                        content: SingleChildScrollView(
                                          child: Text(
                                            data['description'] ?? 'No description available',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text('View Details'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
