import 'package:cloud_firestore/cloud_firestore.dart';

/// Une ligne du panier (devis en cours) d'un client.
class CartItem {
  final String serviceId;
  final String titre;
  final double prix;
  final String duree;
  final String categorieId;
  final int quantite;

  const CartItem({
    required this.serviceId,
    required this.titre,
    required this.prix,
    required this.duree,
    required this.categorieId,
    required this.quantite,
  });

  double get sousTotal => prix * quantite;

  factory CartItem.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return CartItem(
      serviceId: doc.id,
      titre: d['titre'] as String? ?? '',
      prix: (d['prix'] as num?)?.toDouble() ?? 0,
      duree: d['duree'] as String? ?? '',
      categorieId: d['categorieId'] as String? ?? '',
      quantite: (d['quantite'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'titre': titre,
        'prix': prix,
        'duree': duree,
        'categorieId': categorieId,
        'quantite': quantite,
      };
}
