import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studmall2/pages/bottomnav.dart';
import 'dart:io';
import '../services/product_service.dart';
import 'package:flutter/services.dart';

class Add extends StatefulWidget {
  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<Add> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');

  // Variables
  File? _selectedImage;
  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedUniversity;
  bool _isLoading = false;
  bool _imageUploading = false;
  double _uploadProgress = 0.0;

  // Lists
  List<String> _categories = [];
  List<String> _universities = [];

  final List<String> _conditions = [
    'Neuf',
    'Très bon état',
    'Bon état',
    'État correct',
    'À réparer',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categories = await _productService.getCategories();
      final universities = await _productService.getUniversities();

      setState(() {
        _categories = categories;
        _universities = universities;
        _selectedCondition = _conditions[0];
      });
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    }
  }

  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        _showError('Veuillez sélectionner une image');
        return;
      }

      if (_selectedCategory == null) {
        _showError('Veuillez sélectionner une catégorie');
        return;
      }

      setState(() {
        _isLoading = true;
        _imageUploading = true;
        _uploadProgress = 0.0;
      });

      try {
        // Simulate upload progress
        _simulateProgress();

        // Add product
        final result = await _productService.addProduct(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          category: _selectedCategory!,
          imageFile: _selectedImage!,
          stock: int.parse(_stockController.text),
          condition: _selectedCondition!,
          university: _selectedUniversity,
        );

        // Success

        _showSuccessDialog(result);
      } catch (e) {
        _showError('Erreur: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
          _imageUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  void _simulateProgress() {
    const totalSteps = 10;
    var currentStep = 0;

    Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (currentStep >= totalSteps || !_imageUploading) {
        timer.cancel();
        return;
      }

      setState(() {
        _uploadProgress = (currentStep + 1) / totalSteps;
      });

      currentStep++;
    });
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Succès!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Votre produit a été ajouté avec succès.'),
            SizedBox(height: 10),
            SizedBox(height: 10),
            Text(
              'Il est maintenant visible par tous les étudiants.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => BottomNav()),
                (route) => false,
              );
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos du produit *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 10),

        if (_selectedImage != null)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 20),

                    onPressed: () {
                      setState(() => _selectedImage = null);
                    },
                  ),
                ),
              ),
            ],
          )
        else
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  size: 50,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 10),
                Text(
                  'Ajoutez des photos',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 5),
                Text(
                  'La première photo sera la photo principale',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),

        SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.photo_library, size: 20),
                label: Text('Galerie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: Icon(Icons.camera_alt, size: 20),
                label: Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  foregroundColor: Colors.green[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 5),
        Text(
          '* Une photo est obligatoire pour vendre un produit',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ${isRequired ? '*' : ''}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator:
              validator ??
              (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return 'Ce champ est requis';
                }
                return null;
              },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
    bool isRequired = true,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ${isRequired ? '*' : ''}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: value,
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.grey[800]),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: icon != null ? Icon(icon, size: 20) : null,
              ),
              isExpanded: true,
              hint: Text('Sélectionnez...'),
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
              validator: isRequired
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ est requis';
                      }
                      return null;
                    }
                  : null,
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vendre un produit',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Photos
                    _buildImageSection(),

                    SizedBox(height: 24),

                    // Section 2: Informations de base
                    Text(
                      'Informations du produit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildTextField(
                      label: 'Titre du produit',
                      controller: _nameController,
                      icon: Icons.shopping_bag,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrez un titre';
                        }
                        if (value.length < 3) {
                          return 'Titre trop court (min 3 caractères)';
                        }
                        return null;
                      },
                    ),

                    _buildTextField(
                      label: 'Description',
                      controller: _descriptionController,
                      icon: Icons.description,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrez une description';
                        }
                        return null;
                      },
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Prix (Fcfa)',
                            controller: _priceController,
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrez un prix';
                              }
                              final price = double.tryParse(value);
                              if (price == null) {
                                return 'Prix invalide';
                              }
                              if (price <= 0) {
                                return 'Prix doit être positif';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Stock',
                            controller: _stockController,
                            icon: Icons.inventory,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrez la quantité';
                              }
                              final stock = int.tryParse(value);
                              if (stock == null || stock <= 0) {
                                return 'Quantité invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    // Section 3: Catégorie & État
                    Text(
                      'Détails du produit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildDropdown(
                      label: 'Catégorie',
                      items: _categories,

                      value: _selectedCategory,
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      isRequired: false,
                      icon: Icons.category,
                    ),

                    _buildDropdown(
                      label: 'État',
                      items: _conditions,
                      value: _selectedCondition,
                      onChanged: (value) {
                        setState(() => _selectedCondition = value);
                      },
                      icon: Icons.star,
                    ),

                    _buildDropdown(
                      label: 'Université (optionnel)',
                      items: _universities,
                      value: _selectedUniversity,
                      onChanged: (value) {
                        setState(() => _selectedUniversity = value);
                      },
                      isRequired: false,
                      icon: Icons.school,
                    ),

                    // Section 4: Conseils
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, color: Colors.amber),
                                SizedBox(width: 8),
                                Text(
                                  'Conseils pour bien vendre',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text('• Prenez des photos de qualité'),
                            Text('• Décrivez précisément votre produit'),
                            Text('• Mentionnez les défauts éventuels'),
                            Text('• Fixez un prix raisonnable'),
                            Text('• Répondez rapidement aux messages'),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Conditions
                    Text(
                      'En publiant ce produit, vous acceptez les conditions générales de StudMall.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),

            // Upload progress overlay
            if (_imageUploading)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _uploadProgress,
                          strokeWidth: 4,
                          color: Colors.white,
                        ),
                        SizedBox(height: 20),

                        Text(
                          'Upload de l\'image... ${(_uploadProgress * 100).toInt()}%',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Veuillez patienter',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

      // Floating Action Button for submit
      floatingActionButton: Container(
        margin: EdgeInsets.all(16),
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: _isLoading ? null : _submitProduct,
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          elevation: 4,
          icon: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(Icons.check),
          label: _isLoading
              ? Text('Publication en cours...')
              : Text('Publier l\'annonce'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
