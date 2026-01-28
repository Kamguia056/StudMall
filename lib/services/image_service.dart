// lib/services/image_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;

class ImageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode 1: Stocker l'image en base64 dans Firestore
  Future<String> uploadImageToFirestore({
    required File imageFile,
    required String productId,
    int maxSizeKB = 500, // Taille maximale en KB
  }) async {
    try {
      // 1. Compresser l'image
      File compressedFile = await _compressImage(
        imageFile,
        maxSizeKB: maxSizeKB,
      );

      // 2. Convertir en base64
      List<int> imageBytes = await compressedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // 3. Stocker dans Firestore
      await _firestore.collection('product_images').doc(productId).set({
        'imageData': base64Image,
        'productId': productId,
        'uploadedAt': FieldValue.serverTimestamp(),
        'format': 'base64',
        'sizeKB': imageBytes.length / 1024,
      });

      return base64Image;
    } catch (e) {
      print('Erreur upload Firestore: $e');
      throw Exception('Erreur lors du stockage de l\'image: $e');
    }
  }

  // Méthode 2: Stocker seulement l'URL de l'image (si elle est hébergée ailleurs)
  Future<void> saveImageUrl({
    required String productId,
    required String imageUrl,
  }) async {
    await _firestore.collection('products').doc(productId).update({
      'imageUrl': imageUrl,
      'hasImage': true,
    });
  }

  // Méthode 3: Utiliser un service d'hébergement gratuit
  Future<String> uploadToFreeHosting(File imageFile) async {
    // Vous pouvez utiliser un service comme:
    // - ImgBB (gratuit, API disponible)
    // - Cloudinary (gratuit jusqu'à 25GB)
    // - imgur
    // - ou votre propre serveur

    // Exemple avec base64 pour stockage local
    List<int> imageBytes = await imageFile.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
  }

  // Compresser l'image
  Future<File> _compressImage(File file, {int maxSizeKB = 500}) async {
    final originalBytes = await file.readAsBytes();
    final originalSizeKB = originalBytes.length / 1024;

    if (originalSizeKB <= maxSizeKB) {
      return file;
    }

    // Décoder l'image
    final image = img.decodeImage(originalBytes);
    if (image == null) {
      throw Exception('Impossible de décoder l\'image');
    }

    // Calculer le ratio de compression
    double compressionRatio = maxSizeKB / originalSizeKB;

    // Redimensionner si nécessaire
    img.Image resizedImage;
    if (compressionRatio < 0.5) {
      int newWidth = (image.width * 0.7).toInt();
      int newHeight = (image.height * 0.7).toInt();
      resizedImage = img.copyResize(image, width: newWidth, height: newHeight);
    } else {
      resizedImage = image;
    }

    // Encoder en JPEG avec qualité réduite
    int quality = (85 * compressionRatio).toInt();
    quality = quality.clamp(30, 85); // Min 30%, Max 85%

    List<int> compressedBytes = img.encodeJpg(resizedImage, quality: quality);

    // Sauvegarder dans un fichier temporaire
    final tempDir = Directory.systemTemp;
    final tempFile = File(
      '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(compressedBytes);

    return tempFile;
  }

  // Récupérer une image depuis Firestore
  Future<Uint8List?> getImageFromFirestore(String productId) async {
    try {
      final doc = await _firestore
          .collection('product_images')
          .doc(productId)
          .get();

      if (doc.exists && doc.data() != null) {
        String base64Image = doc.data()!['imageData'];
        return base64Decode(base64Image);
      }
      return null;
    } catch (e) {
      print('Erreur récupération image: $e');
      return null;
    }
  }
}
