import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> ajouterClient() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('clients').add({
        'nom': _nomController.text,
        'telephone': _telController.text,
        'email': _emailController.text,
        'status': 'actif',
        'date_inscription': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Client ajouté avec succès")),
      );

      _nomController.clear();
      _telController.clear();
      _emailController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un Client')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                    value!.isEmpty ? 'Entrez le nom du client' : null,
              ),
              TextFormField(
                controller: _telController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                validator: (value) =>
                    value!.isEmpty ? 'Entrez le téléphone' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Entrez l’email' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: ajouterClient,
                child: const Text('Ajouter'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
