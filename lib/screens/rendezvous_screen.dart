import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/rendezvous_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import 'rendezvous_form_screen.dart';

/// Liste des rendez-vous du client + accès à la prise de RDV.
class RendezvousScreen extends StatelessWidget {
  const RendezvousScreen({super.key});

  static const _statutColors = {
    'planifié': AppColors.primary,
    'annulé': AppColors.danger,
    'terminé': AppColors.purple,
    'en cours': AppColors.warning,
  };

  void _nouveau(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RendezvousFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes rendez-vous',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: RendezvousService.instance.watchClient(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return _buildEmpty();

          docs.sort((a, b) => (b.data()['date'] as String? ?? '')
              .compareTo(a.data()['date'] as String? ?? ''));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, i) =>
                _buildCard(context, docs[i].id, docs[i].data()),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _nouveau(context),
        backgroundColor: AppColors.primaryDark,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Prendre RDV', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String id, Map<String, dynamic> d) {
    final statut = d['statut'] as String? ?? 'planifié';
    final color = _statutColors[statut] ?? AppColors.textMuted;
    final date = DateTime.tryParse(d['date'] as String? ?? '');
    final annulable = statut == 'planifié';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  d['service'] as String? ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textDark),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statut,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (date != null)
            Row(
              children: [
                const Icon(Icons.event,
                    size: 16, color: AppColors.textLight),
                const SizedBox(width: 6),
                Text(Format.dateHeure(date),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          if ((d['adresse'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.textLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(d['adresse'] as String,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
                ),
              ],
            ),
          ],
          if (annulable) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => RendezvousService.instance.annuler(id),
                icon: const Icon(Icons.cancel_outlined,
                    size: 16, color: AppColors.danger),
                label: const Text('Annuler',
                    style: TextStyle(color: AppColors.danger)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_available,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Aucun rendez-vous',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('Prenez rendez-vous avec un garage mobile',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
