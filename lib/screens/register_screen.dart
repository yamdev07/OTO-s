import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String error = '';
  bool isLoading = false;

  Future<void> _register() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      // Crée l'utilisateur
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      // Enregistre les infos dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': emailCtrl.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      Navigator.pop(context); // Retourne à l'écran précédent (login)
    } catch (e) {
      setState(() {
        error = "Erreur d'inscription : ${e.toString()}";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('S\'inscrire'),
                  ),
            const SizedBox(height: 10),
            if (error.isNotEmpty)
              Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("J'ai déjà un compte"),
            )
          ],
        ),
      ),
    );
  }
}
