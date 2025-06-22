import 'package:flutter/material.dart';

class CompteScreen extends StatelessWidget {
  const CompteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Compte")),
      body: const Center(child: Text("Profil utilisateur")),
    );
  }
}
