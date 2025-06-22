import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nous Contacter")),
      body: const Center(child: Text("Infos de contact et assistance")),
    );
  }
}
