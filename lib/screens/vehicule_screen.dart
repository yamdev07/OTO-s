import 'package:flutter/material.dart';

class VehiculeScreen extends StatelessWidget {
  const VehiculeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Véhicule")),
      body: const Center(child: Text("Infos de mon véhicule")),
    );
  }
}
