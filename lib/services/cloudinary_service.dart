// lib/services/cloudinary_simple_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinarySimpleService {
  // NE PAS mettre l'API Secret ici pour les uploads non signés
  static const String _cloudName = 'VOTRE_CLOUD_NAME';
  static const String _uploadPreset =
      'unsigned_preset'; // Le preset que vous avez créé

  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  // Méthode ultra-simple avec upload preset
  static Future<String> uploadImageWithPreset(File imageFile) async {
    try {
      print('=== UPLOAD AVEC PRESET ===');

      // Vérifier que le preset existe
      if (_uploadPreset.isEmpty) {
        throw Exception(
          'Upload preset non configuré. Créez-en un dans Cloudinary Dashboard.',
        );
      }

      // Créer la requête multipart
      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      // Ajouter seulement le preset et le fichier
      request.fields['upload_preset'] = _uploadPreset;

      // Ajouter le fichier
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Envoyer
      print('Envoi vers Cloudinary...');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Status: ${response.statusCode}');
      print('Response: $responseBody');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        final secureUrl = jsonResponse['secure_url'];

        if (secureUrl != null) {
          print('✅ Upload réussi: $secureUrl');
          return secureUrl as String;
        } else {
          throw Exception('URL sécurisée non trouvée dans la réponse');
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('❌ Erreur upload: $e');
      rethrow;
    }
  }

  // Méthode avec base64 (alternative)
  static Future<String> uploadImageBase64(File imageFile) async {
    try {
      // Lire et encoder l'image
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Préparer le corps
      Map<String, String> body = {
        'file': 'data:image/jpeg;base64,$base64Image',
        'upload_preset': _uploadPreset,
      };

      // Envoyer
      var response = await http.post(Uri.parse(_uploadUrl), body: body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['secure_url'] as String;
      } else {
        throw Exception('Erreur: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Tester la connexion
  static Future<void> testConnection() async {
    print('=== TEST CONNEXION CLOUDINARY ===');
    print('Cloud Name: $_cloudName');
    print('Upload Preset: $_uploadPreset');

    // Créer une image test simple
    final pixels = List<int>.filled(
      4 * 100 * 100,
      255,
    ); // Image blanche 100x100
    final base64Test = base64Encode(pixels);

    try {
      var response = await http.post(
        Uri.parse(_uploadUrl),
        body: {
          'file': 'data:image/png;base64,$base64Test',
          'upload_preset': _uploadPreset,
        },
      );

      if (response.statusCode == 200) {
        print('✅ Connexion Cloudinary OK');
        final jsonResponse = json.decode(response.body);
        print('URL test: ${jsonResponse['secure_url']}');
      } else {
        print('❌ Erreur: ${response.statusCode}');
        print('Réponse: ${response.body}');
        throw Exception('Échec de connexion');
      }
    } catch (e) {
      print('❌ Exception: $e');
      throw Exception('Impossible de se connecter à Cloudinary: $e');
    }
  }
}
