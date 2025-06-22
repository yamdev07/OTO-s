import 'package:flutter/material.dart';

class PrestationsScreen extends StatelessWidget {
  const PrestationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nos Prestations")),
      body: const Center(child: Text("Liste des services disponibles")),
    );
  }
}
