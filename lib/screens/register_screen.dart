import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navigation_screen.dart'; // Redirection après inscription
import 'mecano_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _mdpController = TextEditingController();
  final TextEditingController _mdpConfirmController = TextEditingController();

  String? _role;
  String selectedCountryCode = '+229';
  bool isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _mdpController.dispose();
    _mdpConfirmController.dispose();
    super.dispose();
  }

  void _continue() async {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() {
          _currentStep += 1;
        });
      } else {
        if (_role == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez sélectionner un rôle')),
          );
          return;
        }

        final fullPhone = '$selectedCountryCode ${_telController.text.trim()}';
        setState(() => isLoading = true);

        try {
          final userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _mdpController.text.trim(),
          );

          final user = userCredential.user;
          final uid = user?.uid;

          if (uid != null) {
            final String collectionName =
                _role == 'Mécano' ? 'prestataires' : 'clients';

            await FirebaseFirestore.instance
                .collection(collectionName)
                .doc(uid)
                .set({
              'uid': uid,
              'nom': _nomController.text.trim(),
              'prenom': _prenomController.text.trim(),
              'email': _emailController.text.trim(),
              'telephone': fullPhone,
              'role': _role,
              'status': 'actif',
              'createdAt': FieldValue.serverTimestamp(),
              'sendWelcomeEmail': true,
            });

            if (_role == 'Particulier') {
              await FirebaseFirestore.instance
                  .collection('clients')
                  .doc(uid)
                  .collection('vehicules')
                  .add({
                'marque': 'À définir',
                'modele': 'À définir',
                'immatriculation': '',
                'date_creation': FieldValue.serverTimestamp(),
                'principal': true,
              });
            }

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inscription réussie !')),
            );

            if (_role == 'Mécano') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const MecanoDashboardScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const NavigationScreen()),
              );
            }
          }
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : ${e.message}')),
          );
        } finally {
          setState(() => isLoading = false);
        }
      }
    }
  }

  void _cancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: _continue,
              onStepCancel: _cancel,
              steps: [
                Step(
                  title: const Text('Nom & Prénom'),
                  isActive: _currentStep >= 0,
                  content: Form(
                    key: _formKeys[0],
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nomController,
                          decoration: const InputDecoration(labelText: 'Nom'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Champ obligatoire'
                              : null,
                        ),
                        TextFormField(
                          controller: _prenomController,
                          decoration:
                              const InputDecoration(labelText: 'Prénom'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Champ obligatoire'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  title: const Text('Email & Téléphone'),
                  isActive: _currentStep >= 1,
                  content: Form(
                    key: _formKeys[1],
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Champ obligatoire';
                            if (!value.contains('@')) return 'Email invalide';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: selectedCountryCode,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(
                                      value: '+229', child: Text('Bénin +229')),
                                  DropdownMenuItem(
                                      value: '+33', child: Text('France +33')),
                                  DropdownMenuItem(
                                      value: '+1', child: Text('USA +1')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedCountryCode = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _telController,
                                decoration: const InputDecoration(
                                  labelText: 'Numéro de téléphone',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Champ obligatoire'
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  title: const Text('Mot de passe & rôle'),
                  isActive: _currentStep >= 2,
                  content: Form(
                    key: _formKeys[2],
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _mdpController,
                          decoration:
                              const InputDecoration(labelText: 'Mot de passe'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Champ obligatoire';
                            if (value.length < 6) return 'Minimum 6 caractères';
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _mdpConfirmController,
                          decoration: const InputDecoration(
                              labelText: 'Confirmer mot de passe'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty){
                              return 'Champ obligatoire';
                            }
                            if (value != _mdpController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        const Text('Vous êtes :'),
                        ListTile(
                          title: const Text('Mécano'),
                          leading: Radio<String>(
                            value: 'Mécano',
                            groupValue: _role,
                            onChanged: (value) {
                              setState(() {
                                _role = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Particulier'),
                          leading: Radio<String>(
                            value: 'Particulier',
                            groupValue: _role,
                            onChanged: (value) {
                              setState(() {
                                _role = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
