import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Accès au document client (`clients/{uid}`) : profil, crédit, parrainage.
class ClientService {
  ClientService._();
  static final instance = ClientService._();

  DocumentReference<Map<String, dynamic>>? _ref() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('clients').doc(uid);
  }

  CollectionReference<Map<String, dynamic>>? _transactions() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('clients')
        .doc(uid)
        .collection('transactions');
  }

  /// Flux temps réel du document client.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watch() {
    final ref = _ref();
    if (ref == null) return const Stream.empty();
    return ref.snapshots();
  }

  /// Met à jour les informations personnelles.
  Future<void> updateProfil({
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    final ref = _ref();
    if (ref == null) return;
    await ref.set({
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
    }, SetOptions(merge: true));
  }

  /// Crédite le compte d'un montant et journalise la transaction.
  Future<void> crediter(double montant, {String libelle = 'Rechargement'}) async {
    final ref = _ref();
    final tx = _transactions();
    if (ref == null || tx == null) return;
    await ref.set({'credit': FieldValue.increment(montant)},
        SetOptions(merge: true));
    await tx.add({
      'libelle': libelle,
      'montant': montant,
      'type': 'credit',
      'date': DateTime.now().toIso8601String(),
    });
  }

  /// Débite le compte (paiement d'un devis). Renvoie false si solde insuffisant.
  Future<bool> debiter(double montant, {String libelle = 'Paiement'}) async {
    final ref = _ref();
    final tx = _transactions();
    if (ref == null || tx == null) return false;
    final ok = await FirebaseFirestore.instance.runTransaction((t) async {
      final snap = await t.get(ref);
      final solde = (snap.data()?['credit'] as num?)?.toDouble() ?? 0;
      if (solde < montant) return false;
      t.set(ref, {'credit': solde - montant}, SetOptions(merge: true));
      return true;
    });
    if (ok) {
      await tx.add({
        'libelle': libelle,
        'montant': -montant,
        'type': 'debit',
        'date': DateTime.now().toIso8601String(),
      });
    }
    return ok;
  }

  /// Flux des transactions (crédit/débit).
  Stream<QuerySnapshot<Map<String, dynamic>>> watchTransactions() {
    final tx = _transactions();
    if (tx == null) return const Stream.empty();
    return tx.snapshots();
  }

  /// Retourne (en le créant si besoin) le code de parrainage du client.
  /// Le code est dérivé de l'uid pour rester stable et unique.
  Future<String> codeParrainage() async {
    final ref = _ref();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (ref == null || uid == null) return '';
    final snap = await ref.get();
    final existant = snap.data()?['codeParrainage'] as String?;
    if (existant != null && existant.isNotEmpty) return existant;
    final code = 'OTO${uid.substring(0, 5).toUpperCase()}';
    await ref.set({'codeParrainage': code}, SetOptions(merge: true));
    return code;
  }
}
