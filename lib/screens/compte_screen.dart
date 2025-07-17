import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'devis_screen.dart';

class CompteScreen extends StatefulWidget {
  const CompteScreen({super.key});

  @override
  State<CompteScreen> createState() => _CompteScreenState();
}

class _CompteScreenState extends State<CompteScreen> {
  String email = '';
  String nom = '';
  bool isLoading = true;
  bool isEditing = false;
  final TextEditingController _nomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('clients') // 🔄 Collection corrigée
            .doc(user.uid)
            .get();
        setState(() {
          email = user.email ?? 'Email non défini';
          nom = doc.exists
              ? (doc['nom'] ?? user.displayName ?? 'Nom non défini')
              : user.displayName ?? 'Nom non défini';
          _nomController.text = nom;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors du chargement : $e")),
        );
      }
    }
  }

  Future<void> _updateNom() async {
    final user = FirebaseAuth.instance.currentUser;
    final newNom = _nomController.text.trim();

    if (user == null || newNom.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('clients') // 🔄 Collection corrigée
          .doc(user.uid)
          .update({'nom': newNom});
      setState(() {
        nom = newNom;
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nom mis à jour avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de mise à jour : $e")),
      );
    }
  }

  Future<void> _changePassword() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("E-mail de réinitialisation envoyé")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Mon Compte"),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor,
                      backgroundImage:
                          const AssetImage('assets/images/avatar.png'),
                      child: nom.isEmpty
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 20),

                    /// NOM + ÉDITION
                    isEditing
                        ? Column(
                            children: [
                              TextField(
                                controller: _nomController,
                                decoration: const InputDecoration(
                                  labelText: "Nouveau nom",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: _updateNom,
                                icon: const Icon(Icons.check),
                                label: const Text("Enregistrer"),
                                style: _buttonStyle(),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() => isEditing = false);
                                },
                                child: const Text("Annuler"),
                              )
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                nom,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() => isEditing = true);
                                },
                                icon: const Icon(Icons.edit, size: 20),
                              )
                            ],
                          ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    _buildButton(Icons.lock_reset, "Changer le mot de passe", _changePassword),
                    const SizedBox(height: 10),
                    _buildButton(Icons.logout, "Se déconnecter", () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }),
                    const SizedBox(height: 10),
                    _buildButton(Icons.refresh, "Rafraîchir", () {
                      setState(() => isLoading = true);
                      _loadUserInfo();
                    }),
                    const SizedBox(height: 10),
                    _buildButton(Icons.request_quote, "Mes devis", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DevisScreen()),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: _buttonStyle(),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.accentColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 3,
      textStyle: const TextStyle(fontSize: 16),
    );
  }
}
