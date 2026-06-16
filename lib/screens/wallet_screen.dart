import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/client_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';

/// Portefeuille de crédit O'TO : solde, rechargement et historique.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const _montants = [5000, 10000, 25000, 50000];

  Future<void> _recharger(BuildContext context, int montant) async {
    await ClientService.instance
        .crediter(montant.toDouble(), libelle: 'Rechargement crédit');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compte rechargé de ${Format.fcfa(montant)}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon crédit',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildBalanceCard(),
          const SizedBox(height: 24),
          const Text('Recharger mon compte',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 12),
          _buildRechargeGrid(context),
          const SizedBox(height: 24),
          const Text('Historique',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 12),
          _buildHistory(),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ClientService.instance.watch(),
      builder: (context, snap) {
        final solde =
            (snap.data?.data()?['credit'] as num?)?.toDouble() ?? 0;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text('Solde disponible',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                Format.fcfa(solde),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRechargeGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: _montants
          .map((m) => InkWell(
                onTap: () => _recharger(context, m),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          Format.fcfa(m),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildHistory() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ClientService.instance.watchTransactions(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('Aucune transaction',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
          );
        }
        docs.sort((a, b) => (b.data()['date'] as String? ?? '')
            .compareTo(a.data()['date'] as String? ?? ''));

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(docs.length, (i) {
              final d = docs[i].data();
              final montant = (d['montant'] as num?)?.toDouble() ?? 0;
              final estCredit = montant >= 0;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (estCredit ? AppColors.success : AppColors.danger)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        estCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: estCredit ? AppColors.success : AppColors.danger,
                        size: 18,
                      ),
                    ),
                    title: Text(d['libelle'] as String? ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(Format.dateCourte(d['date'] as String?),
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 12)),
                    trailing: Text(
                      '${estCredit ? '+' : ''}${Format.fcfa(montant)}',
                      style: TextStyle(
                        color: estCredit ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (i < docs.length - 1)
                    const Divider(height: 1, indent: 64, endIndent: 16),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
