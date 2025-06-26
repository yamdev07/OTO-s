import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/navigation_screen.dart';
import 'screens/login_screen.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const NavigationScreen(),
    );
  }
}
