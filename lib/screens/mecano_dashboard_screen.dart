import 'package:flutter/material.dart';

class MecanoDashboardScreen extends StatelessWidget {
  const MecanoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tableau de bord Mécano")),
      body: const Center(child: Text("Bienvenue mécano 🚗")),
    );
  }
}
