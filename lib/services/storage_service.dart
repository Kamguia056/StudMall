// lib/services/storage_service.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload d'image
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      // Vérifier si le fichier existe localement
      if (!await imageFile.exists()) {
        throw Exception('Le fichier image n\'existe pas localement');
      }

      // Créer une référence unique
      String fileName =
          'products/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);

      // Upload avec metadata
      UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploadedBy': 'user', 'productId': productId},
        ),
      );

      // Attendre la fin de l'upload
      TaskSnapshot snapshot = await uploadTask;

      // Vérifier si l'upload a réussi
      if (snapshot.state == TaskState.success) {
        // Récupérer l'URL de téléchargement
        String downloadUrl = await storageRef.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception('Échec de l\'upload');
      }
    } on FirebaseException catch (e) {
      print('Erreur Firebase Storage: ${e.code} - ${e.message}');
      throw Exception('Erreur lors de l\'upload: ${e.message}');
    } catch (e) {
      print('Erreur générale: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Vérifier si une image existe
  Future<bool> imageExists(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return false;

      // Extraire le chemin du fichier de l'URL
      Uri uri = Uri.parse(imageUrl);
      String path = uri.path;

      // Prendre seulement la partie après /v0/b/[bucket]/o/
      List<String> parts = path.split('/');
      if (parts.length < 6) return false;

      String filePath = parts
          .sublist(5)
          .join('/')
          .replaceAll('%2F', '/')
          .replaceAll('%20', ' ');

      // Vérifier l'existence
      Reference ref = _storage.ref().child(filePath);
      final metadata = await ref.getMetadata();
      // ignore: unnecessary_null_comparison
      return metadata != null;
    } catch (e) {
      return false;
    }
  }
}
