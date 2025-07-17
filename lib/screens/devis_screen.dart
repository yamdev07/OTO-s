import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DevisScreen extends StatefulWidget {
  const DevisScreen({super.key});

  @override
  State<DevisScreen> createState() => _DevisScreenState();
}

class _DevisScreenState extends State<DevisScreen> {
  final _formKey = GlobalKey<FormState>();
  final prestationController = TextEditingController();
  final descriptionController = TextEditingController();
  final prixController = TextEditingController();

  Future<void> createDevis() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('devis').add({
        'clientId': user.uid,
        'prestation': prestationController.text.trim(),
        'description': descriptionController.text.trim(),
        'prixEstime': int.tryParse(prixController.text) ?? 0,
        'statut': 'en attente',
        'date': DateTime.now().toIso8601String(),
      });

      // Nettoyer les champs après l'envoi
      prestationController.clear();
      descriptionController.clear();
      prixController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Devis envoyé avec succès")),
      );
    }
  }

  @override
  void dispose() {
    prestationController.dispose();
    descriptionController.dispose();
    prixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes devis"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Formulaire de création de devis
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: prestationController,
                    decoration: const InputDecoration(labelText: "Type de prestation"),
                    validator: (value) => value!.isEmpty ? "Champ requis" : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                    validator: (value) => value!.isEmpty ? "Champ requis" : null,
                  ),
                  TextFormField(
                    controller: prixController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Prix estimé (FCFA)"),
                    validator: (value) => value!.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        createDevis();
                      }
                    },
                    child: const Text("Créer le devis"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Divider(),
            const SizedBox(height: 12),

            // Affichage des devis
            const Text("Historique des devis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('devis')
                  .where('clientId', isEqualTo: user?.uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final devisList = snapshot.data?.docs ?? [];

                if (devisList.isEmpty) {
                  return const Text("Aucun devis trouvé.");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: devisList.length,
                  itemBuilder: (context, index) {
                    final devis = devisList[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(devis['prestation']),
                        subtitle: Text(devis['description']),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("${devis['prixEstime']} FCFA"),
                            Text("Statut : ${devis['statut']}"),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
