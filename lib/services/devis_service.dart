import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item.dart';

/// Création et gestion des devis dans Firestore (collection `devis`).
class DevisService {
  DevisService._();
  static final instance = DevisService._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('devis');

  /// Crée un devis itemisé à partir du contenu du panier.
  /// Retourne l'identifiant du devis créé.
  Future<String?> creerDepuisPanier(
    List<CartItem> items, {
    String? vehicule,
    String? note,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || items.isEmpty) return null;

    final total = items.fold<double>(0, (acc, e) => acc + e.sousTotal);
    final doc = await _col.add({
      'clientId': uid,
      'items': items
          .map((e) => {
                'serviceId': e.serviceId,
                'titre': e.titre,
                'prix': e.prix,
                'quantite': e.quantite,
                'sousTotal': e.sousTotal,
              })
          .toList(),
      // Champs de compatibilité avec l'ancien écran de devis.
      'prestation': items.length == 1
          ? items.first.titre
          : '${items.length} prestations',
      'description': note?.trim().isNotEmpty == true
          ? note!.trim()
          : items.map((e) => '${e.quantite}× ${e.titre}').join(', '),
      'prixEstime': total.round(),
      'total': total,
      'vehicule': vehicule ?? '',
      'statut': 'en attente',
      'paye': false,
      'date': DateTime.now().toIso8601String(),
    });
    return doc.id;
  }

  /// Crée un devis « libre » à partir du formulaire manuel.
  Future<void> creerManuel({
    required String prestation,
    required String description,
    required int prixEstime,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _col.add({
      'clientId': uid,
      'prestation': prestation,
      'description': description,
      'prixEstime': prixEstime,
      'total': prixEstime,
      'statut': 'en attente',
      'paye': false,
      'date': DateTime.now().toIso8601String(),
    });
  }
}
