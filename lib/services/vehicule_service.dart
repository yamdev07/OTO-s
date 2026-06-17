import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// CRUD des véhicules d'un client, sous `clients/{uid}/vehicules`.
class VehiculeService {
  VehiculeService._();
  static final instance = VehiculeService._();

  CollectionReference<Map<String, dynamic>>? _col() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('clients')
        .doc(uid)
        .collection('vehicules');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watch() {
    final col = _col();
    if (col == null) return const Stream.empty();
    return col.snapshots();
  }

  Future<void> ajouter(Map<String, dynamic> data) async {
    final col = _col();
    if (col == null) return;
    // Premier véhicule => principal par défaut.
    final existants = await col.get();
    final estPremier = existants.docs.isEmpty;
    await col.add({
      ...data,
      'principal': data['principal'] ?? estPremier,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> modifier(String id, Map<String, dynamic> data) async {
    final col = _col();
    if (col == null) return;
    await col.doc(id).update(data);
  }

  Future<void> supprimer(String id) async {
    final col = _col();
    if (col == null) return;
    await col.doc(id).delete();
  }

  /// Définit un véhicule comme principal (et retire le statut aux autres).
  Future<void> definirPrincipal(String id) async {
    final col = _col();
    if (col == null) return;
    final docs = await col.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in docs.docs) {
      batch.update(d.reference, {'principal': d.id == id});
    }
    await batch.commit();
  }
}
