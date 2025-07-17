import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehiculeScreen extends StatelessWidget {
  const VehiculeScreen({super.key});

  Future<QuerySnapshot> _loadVehicules() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('clients')
        .doc(uid)
        .collection('vehicules')
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon véhicule")),
      body: FutureBuilder<QuerySnapshot>(
        future: _loadVehicules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun véhicule enregistré"));
          }

          final data = snapshot.data!.docs.first;
          final vehicule = data.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(
                    "${vehicule['marque'] ?? ''} ${vehicule['modele'] ?? ''}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text("Immatriculation : ${vehicule['immatriculation'] ?? 'Non renseignée'}"),
                    Text("Principal : ${vehicule['principal'] == true ? 'Oui' : 'Non'}"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
