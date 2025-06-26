import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class CompteScreen extends StatefulWidget {
  const CompteScreen({super.key});

  @override
  State<CompteScreen> createState() => _CompteScreenState();
}

class _CompteScreenState extends State<CompteScreen> {
  String email = '';
  String nom = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        email = doc['email'] ?? '';
        nom = doc['nom'] ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("E-mail de réinitialisation envoyé")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Compte")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/avatar.png'), // image par défaut
                  ),
                  const SizedBox(height: 10),
                  Text(nom.isNotEmpty ? nom : "Nom non défini", style: const TextStyle(fontSize: 20)),
                  Text(email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _changePassword,
                    icon: const Icon(Icons.lock_reset),
                    label: const Text("Changer le mot de passe"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Se déconnecter"),
                  ),
                ],
              ),
            ),
    );
  }
}
