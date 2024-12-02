import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});
  @override
  AddPropertyScreenState createState() => AddPropertyScreenState();
}

class AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _imageBase64;
  String _imageDescription = '';
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _bedsController = TextEditingController();
  final _bathsController = TextEditingController();
  final _sqftController = TextEditingController();
  final _priceController = TextEditingController();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> savePropertyWithImage() async {
    try {
      // Validate image and description before saving
      if (_imageBase64 == null || _imageBase64!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload an image')),
        );
        return;
      }

      if (_imageDescription.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a description')),
        );
        return;
      }

      // Update propertyData to include the image directly
      final propertyData = {
        'id': DateTime.now().toString(),
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'beds': int.tryParse(_bedsController.text) ?? 0,
        'baths': int.tryParse(_bathsController.text) ?? 0,
        'sqft': double.tryParse(_sqftController.text) ?? 0.0,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'imageDescription': _imageDescription.trim(),
        'imageBase64': _imageBase64, // Add the image directly to the document
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add the document to Firestore
      await FirebaseFirestore.instance
          .collection('properties')
          .add(propertyData);

      // Remove the subcollection creation since we're storing the image directly

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property added successfully!')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding property: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Property'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_imageBase64 != null)
                Image.memory(
                  base64Decode(_imageBase64!),
                  height: 200,
                  fit: BoxFit.cover,
                  semanticLabel: _imageDescription,
                ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Image'),
              ),
              if (_imageBase64 != null)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Tell us about the property',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _imageDescription = value;
                    });
                  },
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please add a description' : null,
                ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                decoration: InputDecoration(labelText: 'Property Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter property name' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter location' : null,
              ),
              TextFormField(
                controller: _bedsController,
                decoration: InputDecoration(labelText: 'Beds'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter number of beds' : null,
              ),
              TextFormField(
                controller: _bathsController,
                decoration: InputDecoration(labelText: 'Baths'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter number of baths' : null,
              ),
              TextFormField(
                controller: _sqftController,
                decoration: InputDecoration(labelText: 'Square Feet'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter square feet' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter price' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (_imageBase64 == null || _imageBase64!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please upload an image')),
                      );
                      return;
                    }
                    
                    if (_imageDescription.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please add a description')),
                      );
                      return;
                    }

                    await savePropertyWithImage();
                  }
                },
                child: const Text('Save Property'),
              ),
                  ]
                ),
            
              ),
            ],
          ),
        ),
      ),
    );
  }
}