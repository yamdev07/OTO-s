import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/devis.dart';
import '../services/devis_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';

/// Détail d'un devis : lignes, total, statut et paiement.
class DevisDetailScreen extends StatelessWidget {
  final String devisId;
  const DevisDetailScreen({super.key, required this.devisId});

  static const _statusColors = {
    'en attente': AppColors.warning,
    'accepté': AppColors.success,
    'payé': AppColors.success,
    'refusé': AppColors.danger,
    'en cours': AppColors.primary,
    'terminé': AppColors.purple,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail du devis',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: DevisService.instance.watchOne(devisId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Devis introuvable'));
          }
          final devis = Devis.fromDoc(snap.data!);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildStatusHeader(devis),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(Devis devis) {
    final color = _statusColors[devis.statut] ?? AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              devis.paye ? Icons.verified : Icons.request_quote,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  devis.prestation.isEmpty ? 'Devis' : devis.prestation,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Émis le ${Format.dateCourte(devis.date)}',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              devis.statut,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
