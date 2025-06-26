import 'package:flutter/material.dart';
import '../models/prestation.dart';

class PrestationsScreen extends StatelessWidget {
   PrestationsScreen({super.key});

  final List<Prestation> prestations = [
    Prestation(
      titre: 'Lavage intérieur/extérieur',
      description: 'Nettoyage complet intérieur et extérieur de votre véhicule',
      image: 'assets/images/lavage.jpg',
      prix: 5000,
    ),
    Prestation(
      titre: 'Vidange moteur',
      description: 'Remplacement de l’huile moteur avec contrôle des niveaux',
      image: 'assets/images/vidange.jpg',
      prix: 15000,
    ),
    Prestation(
      titre: 'Diagnostic électronique',
      description: 'Analyse complète des capteurs et systèmes électroniques',
      image: 'assets/images/diagnostic.jpg',
      prix: 10000,
    ),
    Prestation(
      titre: 'Remplacement plaquettes de frein',
      description: 'Changement complet des plaquettes avant/arrière',
      image: 'assets/images/frein.jpg',
      prix: 20000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nos Prestations")),
      body: ListView.builder(
        itemCount: prestations.length,
        itemBuilder: (context, index) {
          final item = prestations[index];
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 4,
            child: ListTile(
              leading: Image.asset(item.image, width: 60, height: 60, fit: BoxFit.cover),
              title: Text(item.titre),
              subtitle: Text('${item.prix.toStringAsFixed(0)} FCFA'),
              trailing: Icon(Icons.add_shopping_cart),
              onTap: () {
                // TODO: Ajouter au panier
              },
            ),
          );
        },
      ),
    );
  }
}
