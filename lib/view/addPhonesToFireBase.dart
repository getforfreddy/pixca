import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Addphonestofirebase extends StatefulWidget {
  const Addphonestofirebase({Key? key}) : super(key: key);

  @override
  State<Addphonestofirebase> createState() => _AddphonestofirebaseState();
}

class _AddphonestofirebaseState extends State<Addphonestofirebase> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  String? _selectedBrand;
  String? _selectedType;

  List<String> _brands = [
    'Asus',
    'Huawei',
    'Nokia',
    'Motorola',
    'Vivo',
    'Xiaomi',
    'Samsung',
    'Apple',
  ];

  List<int> _selectedRomSizes = [];
  List<int> _selectedRamSizes = [];

  List<int> _ramSizes = [2, 4, 6, 8, 12];
  List<int> _romSizes = [16, 32, 64, 128, 256, 512];

  List<String> _productTypes = ['Phones', 'Watches', 'Accessories'];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> _uploadImage(File image) async {
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('products/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Return an empty string if upload fails
    }
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate() && _image != null) {
      String imageUrl = await _uploadImage(_image!);

      // Split the color input by commas and store as a list
      List<String> colors = _colorController.text.split(',');

      // Generate a unique productId
      String productId = FirebaseFirestore.instance.collection('Products').doc().id;

      await FirebaseFirestore.instance.collection('Products').doc(productId).set({
        'pid': productId,
        'productName': _nameController.text,
        'brand': _selectedBrand,
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
        'image': imageUrl,
        'ROM': _selectedRomSizes, // Save selected ROM sizes
        'color': colors,
        'ram': _selectedRamSizes, // Save selected RAM sizes
        'type': _selectedType,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added successfully')),
      );

      // Clear the form
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _colorController.clear();
      setState(() {
        _image = null;
        _selectedBrand = null;
        _selectedRomSizes = [];
        _selectedRamSizes = [];
        _selectedType = null;
      });
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Phones and Accessories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product name';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedBrand,
                onChanged: (newValue) {
                  setState(() {
                    _selectedBrand = newValue;
                  });
                },
                items: _brands.map((brand) {
                  return DropdownMenuItem<String>(
                    value: brand,
                    child: Text(brand),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Brand'),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a brand';
                  }
                  return null;
                },
              ),
              // Type selection
              DropdownButtonFormField<String>(
                value: _selectedType,
                onChanged: (newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
                items: _productTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Type'),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(labelText: 'Color'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the color';
                  }
                  return null;
                },
              ),

              // RAM selection
              CheckboxListTile(
                value: _selectedRamSizes.isNotEmpty,
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      _selectedRamSizes.clear(); // Clear previous selections
                      _selectedRamSizes.addAll(_ramSizes);
                    } else {
                      _selectedRamSizes.clear(); // Deselect all RAM sizes
                    }
                  });
                },
                title: Text('RAM'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (_selectedRamSizes.isNotEmpty)
                Wrap(
                  children: _ramSizes.map((size) {
                    return CheckboxListTile(
                      title: Text('$size GB'),
                      value: _selectedRamSizes.contains(size),
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            _selectedRamSizes.add(size);
                          } else {
                            _selectedRamSizes.remove(size);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
// ROM selection
              CheckboxListTile(
                value: _selectedRomSizes.isNotEmpty,
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      _selectedRomSizes.clear(); // Clear previous selections
                      _selectedRomSizes.addAll(_romSizes);
                    } else {
                      _selectedRomSizes.clear(); // Deselect all ROM sizes
                    }
                  });
                },
                title: Text('ROM'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (_selectedRomSizes.isNotEmpty)
                Wrap(
                  children: _romSizes.map((size) {
                    return CheckboxListTile(
                      title: Text('$size GB'),
                      value: _selectedRomSizes.contains(size),
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            _selectedRomSizes.add(size);
                          } else {
                            _selectedRomSizes.remove(size);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),

              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: _image == null
                      ? Icon(Icons.add_a_photo, color: Colors.grey[700], size: 50)
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
