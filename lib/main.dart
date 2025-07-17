import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/role_redirector.dart'; // Import du widget de redirection
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
            return const RoleRedirector(); // 🔄 Redirection automatique selon le rôle
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
