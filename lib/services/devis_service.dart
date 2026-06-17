import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item.dart';

/// Résultat d'une tentative de paiement.
enum PaiementResultat { succes, soldeInsuffisant, erreur }

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

  /// Paie un devis avec le crédit du compte, de façon atomique :
  /// débite le solde du client et marque le devis comme payé dans une
  /// seule transaction Firestore. La transaction est ensuite journalisée.
  Future<PaiementResultat> payerAvecCredit(String devisId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return PaiementResultat.erreur;

    final clientRef =
        FirebaseFirestore.instance.collection('clients').doc(uid);
    final devisRef = _col.doc(devisId);
    double montant = 0;

    try {
      final res = await FirebaseFirestore.instance.runTransaction((tx) async {
        final devisSnap = await tx.get(devisRef);
        final clientSnap = await tx.get(clientRef);
        if (!devisSnap.exists) return PaiementResultat.erreur;

        final dData = devisSnap.data()!;
        if (dData['paye'] == true) return PaiementResultat.succes;

        montant = (dData['total'] as num?)?.toDouble() ??
            (dData['prixEstime'] as num?)?.toDouble() ??
            0;
        final solde = (clientSnap.data()?['credit'] as num?)?.toDouble() ?? 0;
        if (solde < montant) return PaiementResultat.soldeInsuffisant;

        tx.set(clientRef, {'credit': solde - montant},
            SetOptions(merge: true));
        tx.update(devisRef, {
          'paye': true,
          'statut': 'payé',
          'datePaiement': DateTime.now().toIso8601String(),
        });
        return PaiementResultat.succes;
      });

      if (res == PaiementResultat.succes && montant > 0) {
        await clientRef.collection('transactions').add({
          'libelle': 'Paiement devis',
          'montant': -montant,
          'type': 'debit',
          'date': DateTime.now().toIso8601String(),
        });
      }
      return res;
    } catch (_) {
      return PaiementResultat.erreur;
    }
  }

  /// Flux temps réel d'un devis précis.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchOne(String devisId) =>
      _col.doc(devisId).snapshots();

  /// Flux des devis du client courant.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchClient() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _col.where('clientId', isEqualTo: uid).snapshots();
  }

  /// Flux du nombre de devis restant à payer (statut non payé).
  Stream<int> nbAPayer() => watchClient().map(
        (snap) => snap.docs.where((d) => d.data()['paye'] != true).length,
      );

  /// Annule (supprime) un devis non payé.
  Future<void> annuler(String devisId) => _col.doc(devisId).delete();

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
