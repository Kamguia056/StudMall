import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'pages/login.dart';
import 'pages/bottomnav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<AuthService>(create: (_) => AuthService())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Students Store',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

// ======================================
// 👤 WIDGET QUI GÈRE L’AUTHENTIFICATION
// ======================================
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges, // Stream Firebase Auth
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // L’application initialise Firebase
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // Utilisateur connecté → ouvre la section principale
          return const BottomNav();
        } else {
          //  Pas connecté → ouvre login
          return const Login();
        }
      },
    );
  }
}
