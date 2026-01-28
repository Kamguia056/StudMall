import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:studmall2/models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Configuration Cloudinary
  static const String _cloudName = 'deilx6608'; // Remplacez
  static const String _uploadPreset = 'studmall_preset'; // Remplacez

  // Upload image to Cloudinary
  Future<String> uploadToCloudinary(File imageFile) async {
    try {
      final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = 'studmall/products';

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['secure_url'] as String;
      } else {
        throw Exception(
          'Cloudinary error ${response.statusCode}: $responseBody',
        );
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      rethrow;
    }
  }

  // Add product to Firestore
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required double price,
    String? category,
    required File imageFile,
    int stock = 1,
    String condition = 'Neuf',
    String? university,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Upload image to Cloudinary
      String imageUrl = await uploadToCloudinary(imageFile);

      // Generate product ID
      String productId = _firestore.collection('products').doc().id;

      // Prepare product data
      Map<String, dynamic> productData = {
        'id': productId,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'imageUrl': imageUrl,
        'stock': stock,
        'condition': condition,
        'university': university ?? '',
        'sellerId': user.uid,
        'sellerName': user.displayName ?? 'Anonyme',
        'sellerEmail': user.email ?? '',
        'sellerAvatar': user.photoURL ?? '',
        'isAvailable': true,
        'isFeatured': false,
        'rating': 0.0,
        'reviewCount': 0,
        'viewCount': 0,
        'soldCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'location': {'latitude': 0.0, 'longitude': 0.0},
        'tags': _generateTags(name, category ?? 'Autres'),
      };

      // Add to Firestore
      await _firestore.collection('products').doc(productId).set(productData);

      // Also add to user's products subcollection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_products')
          .doc(productId)
          .set({
            'productId': productId,
            'addedAt': FieldValue.serverTimestamp(),
          });

      return {
        'success': true,
        'productId': productId,
        'message': 'Produit ajouté avec succès',
        'imageUrl': imageUrl,
      };
    } catch (e) {
      print('Add product error: $e');
      throw Exception('Erreur: $e');
    }
  }

  // Generate tags for search
  List<String> _generateTags(String name, String category) {
    List<String> tags = [];

    // Add name words
    tags.addAll(name.toLowerCase().split(' '));

    // Add category
    tags.add(category.toLowerCase());

    // Add common tags
    tags.addAll(['étudiant', 'université', 'occasion', 'bon plan']);

    // Remove duplicates and empty strings
    return tags.toSet().where((tag) => tag.isNotEmpty).toList();
  }

  // Get categories from Firestore
  Future<List<String>> getCategories() async {
    // Return default categories if none exist
    return [
      'Livres & Cours',
      'Électronique',
      'Informatique',
      'Vêtements',
      'Fournitures',
      'Logement',
      'Transport',
      'Services',
      'Autres',
    ];
  }

  // Get universities
  Future<List<String>> getUniversities() async {
    return [
      'Université Paris-Saclay',
      'Sorbonne Université',
      'Université Paris Cité',
      'Université de Lyon',
      'Université de Lille',
      'Université de Bordeaux',
      'Université de Toulouse',
      'Université de Strasbourg',
      'Université de Nantes',
      'Université de Montpellier',
      'Autre',
    ];
  }

  // Récupérer tous les produits en temps réel
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Product(
              id: data['id'] ?? '',
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              price: (data['price'] ?? 0).toDouble(),
              category: data['category'] ?? 'Autres',
              imageUrl: data['imageUrl'] ?? '',
              stock: data['stock'] ?? 1,
              condition: data['condition'] ?? 'Neuf',
              university: data['university'] ?? '',
              sellerId: data['sellerId'] ?? '',
              sellerName: data['sellerName'] ?? 'Anonyme',
              sellerEmail: data['sellerEmail'] ?? '',
              sellerAvatar: data['sellerAvatar'] ?? '',
              isAvailable: data['isAvailable'] ?? true,
              isFeatured: data['isFeatured'] ?? false,
              rating: (data['rating'] ?? 0.0).toDouble(),
              reviewCount: data['reviewCount'] ?? 0,
              viewCount: data['viewCount'] ?? 0,
              soldCount: data['soldCount'] ?? 0,
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              updatedAt:
                  (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              location: data['location'] ?? {'latitude': 0.0, 'longitude': 0.0},
              tags: List<String>.from(data['tags'] ?? []),
            );
          }).toList(),
        );
  }
}
