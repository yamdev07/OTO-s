import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'navigation_screen.dart'; // Pour les particuliers
import 'mecano_dashboard_screen.dart'; // Pour les mécanos
import 'login_screen.dart'; // En cas d'erreur ou fallback

class RoleRedirector extends StatelessWidget {
  const RoleRedirector({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('clients').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          return const NavigationScreen(); // 👨‍💼 Particulier
        }

        // Si ce n'est pas un client, on teste prestataire
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('prestataires')
              .doc(uid)
              .get(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snap.hasData && snap.data!.exists) {
              return const MecanoDashboardScreen(); // 👨‍🔧 Mécano
            }

            return const LoginScreen(); // Aucun rôle trouvé
          },
        );
      },
    );
  }
}
