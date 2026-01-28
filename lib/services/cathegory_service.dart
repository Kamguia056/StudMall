import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeDefaultCategories() async {
    try {
      print('Initialisation des catégories...');

      final snapshot = await _firestore.collection('categories').get();

      if (snapshot.docs.isEmpty) {
        final defaultCategories = [
          {
            'name': 'Livres & Cours',
            'icon': '📚',
            'color': '#2196F3',
            'description': 'Manuels, cours, romans universitaires',
            'productCount': 0,
            'isActive': true,
            'order': 1,
          },
          {
            'name': 'Électronique',
            'icon': '💻',
            'color': '#4CAF50',
            'description': 'Ordinateurs, tablettes, smartphones',
            'productCount': 0,
            'isActive': true,
            'order': 2,
          },
          {
            'name': 'Informatique',
            'icon': '🖥️',
            'color': '#FF9800',
            'description': 'PC, composants, accessoires informatiques',
            'productCount': 0,
            'isActive': true,
            'order': 3,
          },
          {
            'name': 'Vêtements',
            'icon': '👕',
            'color': '#E91E63',
            'description': 'Habits, chaussures, accessoires mode',
            'productCount': 0,
            'isActive': true,
            'order': 4,
          },
          {
            'name': 'Fournitures',
            'icon': '✏️',
            'color': '#9C27B0',
            'description': 'Matériel scolaire, papeterie',
            'productCount': 0,
            'isActive': true,
            'order': 5,
          },
          {
            'name': 'Logement',
            'icon': '🏠',
            'color': '#3F51B5',
            'description': 'Location, colocation, meubles',
            'productCount': 0,
            'isActive': true,
            'order': 6,
          },
          {
            'name': 'Transport',
            'icon': '🚗',
            'color': '#00BCD4',
            'description': 'Véhicules, vélos, abonnements',
            'productCount': 0,
            'isActive': true,
            'order': 7,
          },
          {
            'name': 'Services',
            'icon': '🛠️',
            'color': '#795548',
            'description': 'Cours particuliers, réparations',
            'productCount': 0,
            'isActive': true,
            'order': 8,
          },
          {
            'name': 'Autres',
            'icon': '📦',
            'color': '#607D8B',
            'description': 'Toutes les autres catégories',
            'productCount': 0,
            'isActive': true,
            'order': 9,
          },
        ];

        for (var category in defaultCategories) {
          await _firestore.collection('categories').add(category);
          print('✓ Catégorie ajoutée: ${category['name']}');
        }

        print('✅ Toutes les catégories ont été initialisées!');
      } else {
        print(
          'ℹ️ Les catégories existent déjà (${snapshot.docs.length} trouvées)',
        );
      }
    } catch (e) {
      print('❌ Erreur d\'initialisation: $e');
    }
  }

  // Ajouter une seule catégorie
  static Future<void> addCategory({
    required String name,
    String icon = '📦',
    String color = '#607D8B',
    String description = '',
  }) async {
    try {
      await _firestore.collection('categories').add({
        'name': name,
        'icon': icon,
        'color': color,
        'description': description,
        'productCount': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Catégorie "$name" ajoutée avec succès!');
    } catch (e) {
      print('❌ Erreur: $e');
    }
  }
}
