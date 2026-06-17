import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Gestion des rendez-vous, collection top-level `rendezvous`
/// (partagée avec l'espace O'TO PRO côté mécano).
class RendezvousService {
  RendezvousService._();
  static final instance = RendezvousService._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('rendezvous');

  /// Flux des rendez-vous du client courant.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchClient() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _col.where('clientId', isEqualTo: uid).snapshots();
  }

  /// Crée un rendez-vous.
  Future<void> prendre({
    required DateTime date,
    required String service,
    String adresse = '',
    String vehicule = '',
    String? devisId,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _col.add({
      'clientId': uid,
      'service': service,
      'adresse': adresse,
      'vehicule': vehicule,
      'devisId': devisId ?? '',
      'date': date.toIso8601String(),
      'statut': 'planifié',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> annuler(String id) async {
    await _col.doc(id).update({'statut': 'annulé'});
  }

  /// Retourne le prochain rendez-vous planifié (le plus proche dans le futur).
  Future<Map<String, dynamic>?> prochain() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final snap = await _col.where('clientId', isEqualTo: uid).get();
    final now = DateTime.now();
    final futurs = snap.docs
        .map((d) => d.data())
        .where((d) =>
            d['statut'] == 'planifié' &&
            (DateTime.tryParse(d['date'] as String? ?? '')?.isAfter(now) ??
                false))
        .toList()
      ..sort((a, b) =>
          (a['date'] as String).compareTo(b['date'] as String));
    return futurs.isEmpty ? null : futurs.first;
  }
}
