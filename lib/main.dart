import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/role_redirector.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const OtoApp());
}

class OtoApp extends StatelessWidget {
  const OtoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O\'TO Service',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const HomeWithFirebaseTest(); // 🔄 Écran principal avec test intégré
          }

          return const LoginScreen();
        },
      ),
    );
  }
}

/// Widget pour l'écran principal avec bouton de test Firebase
class HomeWithFirebaseTest extends StatelessWidget {
  const HomeWithFirebaseTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oto\'s Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const RoleRedirector(), // Affiche ton contenu habituel selon le rôle
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Ajout d'un document test
                  await FirebaseFirestore.instance.collection('test').add({
                    'message': 'Connexion OK',
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  // Lecture des documents
                  var snapshot = await FirebaseFirestore.instance
                      .collection('test')
                      .get();
                  for (var doc in snapshot.docs) {
                    print(doc.data());
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Test Firebase réussi ! Vérifiez la console.'),
                    ),
                  );
                } catch (e) {
                  print('Erreur Firebase : $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              },
              child: const Text('Tester Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
