import 'package:cloud_firestore/cloud_firestore.dart';

/// Une ligne d'un devis (prestation + quantité).
class DevisLigne {
  final String titre;
  final double prix;
  final int quantite;
  final double sousTotal;

  const DevisLigne({
    required this.titre,
    required this.prix,
    required this.quantite,
    required this.sousTotal,
  });

  factory DevisLigne.fromMap(Map<String, dynamic> m) {
    final prix = (m['prix'] as num?)?.toDouble() ?? 0;
    final qte = (m['quantite'] as num?)?.toInt() ?? 1;
    return DevisLigne(
      titre: m['titre'] as String? ?? '',
      prix: prix,
      quantite: qte,
      sousTotal: (m['sousTotal'] as num?)?.toDouble() ?? prix * qte,
    );
  }
}

/// Un devis client, tel que stocké dans la collection `devis`.
class Devis {
  final String id;
  final String prestation;
  final String description;
  final String vehicule;
  final String statut;
  final double total;
  final bool paye;
  final String date;
  final List<DevisLigne> lignes;

  const Devis({
    required this.id,
    required this.prestation,
    required this.description,
    required this.vehicule,
    required this.statut,
    required this.total,
    required this.paye,
    required this.date,
    required this.lignes,
  });

  factory Devis.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final items = (d['items'] as List?) ?? const [];
    return Devis(
      id: doc.id,
      prestation: d['prestation'] as String? ?? '',
      description: d['description'] as String? ?? '',
      vehicule: d['vehicule'] as String? ?? '',
      statut: d['statut'] as String? ?? 'en attente',
      total: (d['total'] as num?)?.toDouble() ??
          (d['prixEstime'] as num?)?.toDouble() ??
          0,
      paye: d['paye'] == true,
      date: d['date'] as String? ?? '',
      lignes: items
          .map((e) => DevisLigne.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
