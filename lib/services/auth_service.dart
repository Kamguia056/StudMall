// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Connexion avec email/mot de passe
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Erreur de connexion: ${e.code}');
      throw e;
    }
  }

  // Création de compte
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour le profil avec nom et prénom
      await result.user?.updateDisplayName('$firstName $lastName');

      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Erreur d\'inscription: ${e.code}');
      throw e;
    }
  }

  // Mot de passe oublié
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Erreur réinitialisation: ${e.code}');
      throw e;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Vérifier si l'utilisateur est connecté
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  get currentUser => null;
}
