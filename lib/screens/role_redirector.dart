import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'navigation_screen.dart';
import 'mecano_dashboard_screen.dart';
import 'login_screen.dart';

class RoleRedirector extends StatelessWidget {
  const RoleRedirector({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Pas connecté → login
    if (user == null) return const LoginScreen();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        // Client trouvé → espace client
        if (snapshot.hasData && snapshot.data!.exists) {
          return const NavigationScreen();
        }

        // Erreur Firestore (règles, réseau) → espace client par défaut
        if (snapshot.hasError) {
          return const NavigationScreen();
        }

        // Pas dans clients → vérifier prestataires
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('prestataires')
              .doc(user.uid)
              .get(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            // Mécano trouvé → dashboard mécano
            if (snap.hasData && snap.data!.exists) {
              return const MecanoDashboardScreen();
            }

            // Cas inconnu (erreur ou document absent) → espace client par défaut
            return const NavigationScreen();
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
      ),
    );
  }
}
