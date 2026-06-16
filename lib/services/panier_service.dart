import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item.dart';
import '../models/service_item.dart';

/// Gère le panier (devis en cours) d'un client, stocké dans Firestore
/// sous `clients/{uid}/panier/{serviceId}`.
///
/// L'identifiant du document est l'id de la prestation : ajouter deux
/// fois la même prestation incrémente simplement la quantité.
class PanierService {
  PanierService._();
  static final instance = PanierService._();

  CollectionReference<Map<String, dynamic>>? _col() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('clients')
        .doc(uid)
        .collection('panier');
  }

  /// Flux temps réel du contenu du panier.
  Stream<List<CartItem>> watch() {
    final col = _col();
    if (col == null) return const Stream.empty();
    return col.snapshots().map(
          (snap) => snap.docs.map(CartItem.fromDoc).toList(),
        );
  }

  /// Ajoute une prestation au panier (ou +1 si déjà présente).
  Future<void> ajouter(ServiceItem item, String categorieId) async {
    final col = _col();
    if (col == null) return;
    final ref = col.doc(item.id);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final qte = ((snap.data()?['quantite'] as num?)?.toInt() ?? 0) + 1;
      tx.set(ref, {
        'titre': item.titre,
        'prix': item.prix,
        'duree': item.duree,
        'categorieId': categorieId,
        'quantite': qte,
        'addedAt': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Définit la quantité d'une ligne. Quantité <= 0 supprime la ligne.
  Future<void> definirQuantite(String serviceId, int quantite) async {
    final col = _col();
    if (col == null) return;
    if (quantite <= 0) {
      await col.doc(serviceId).delete();
    } else {
      await col.doc(serviceId).update({'quantite': quantite});
    }
  }

  /// Retire complètement une ligne du panier.
  Future<void> retirer(String serviceId) async {
    final col = _col();
    if (col == null) return;
    await col.doc(serviceId).delete();
  }

  /// Vide entièrement le panier (après validation d'un devis par ex.).
  Future<void> vider() async {
    final col = _col();
    if (col == null) return;
    final docs = await col.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in docs.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  /// Calcule le total d'une liste de lignes.
  static double total(List<CartItem> items) =>
      items.fold(0, (acc, e) => acc + e.sousTotal);
}
