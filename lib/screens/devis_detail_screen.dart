import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/devis.dart';
import '../services/devis_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import 'rendezvous_form_screen.dart';
import 'wallet_screen.dart';

/// Détail d'un devis : lignes, total, statut et paiement.
class DevisDetailScreen extends StatefulWidget {
  final String devisId;
  const DevisDetailScreen({super.key, required this.devisId});

  @override
  State<DevisDetailScreen> createState() => _DevisDetailScreenState();
}

class _DevisDetailScreenState extends State<DevisDetailScreen> {
  static const _statusColors = {
    'en attente': AppColors.warning,
    'accepté': AppColors.success,
    'payé': AppColors.success,
    'refusé': AppColors.danger,
    'en cours': AppColors.primary,
    'terminé': AppColors.purple,
  };

  bool _paying = false;

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
        stream: DevisService.instance.watchOne(widget.devisId),
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
              const SizedBox(height: 16),
              if (devis.lignes.isNotEmpty) _buildLignes(devis),
              if (devis.lignes.isNotEmpty) const SizedBox(height: 16),
              _buildRecap(devis),
              const SizedBox(height: 20),
              _buildActions(devis),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------- Actions

  Widget _buildActions(Devis devis) {
    if (devis.paye) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Devis payé. Vous pouvez planifier votre intervention.',
                        style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                      if (devis.datePaiement.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Le ${Format.dateCourte(devis.datePaiement)}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RendezvousFormScreen(
                    servicePrerempli: devis.prestation,
                    devisId: devis.id,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.event_available),
              label: const Text('Prendre rendez-vous',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _paying ? null : () => _ouvrirPaiement(devis),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: _paying
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Icon(Icons.lock_outline),
            label: Text(
              _paying ? 'Paiement...' : 'Payer ${Format.fcfa(devis.total)}',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _paying ? null : () => _confirmerAnnulation(devis.id),
          icon: const Icon(Icons.delete_outline,
              size: 18, color: AppColors.danger),
          label: const Text('Annuler ce devis',
              style: TextStyle(color: AppColors.danger)),
        ),
      ],
    );
  }

  Future<void> _confirmerAnnulation(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler le devis'),
        content: const Text('Ce devis sera définitivement supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Retour'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DevisService.instance.annuler(id);
      if (mounted) Navigator.pop(context);
    }
  }

  void _ouvrirPaiement(Devis devis) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Moyen de paiement',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text('Montant : ${Format.fcfa(devis.total)}',
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 16),
            _moyen(
              icon: Icons.account_balance_wallet,
              titre: 'Crédit O\'TO',
              sousTitre: 'Payer avec votre solde',
              actif: true,
              onTap: () {
                Navigator.pop(ctx);
                _payerCredit(devis);
              },
            ),
            const SizedBox(height: 10),
            _moyen(
              icon: Icons.phone_android,
              titre: 'Mobile Money',
              sousTitre: 'Bientôt disponible',
              actif: false,
            ),
            const SizedBox(height: 10),
            _moyen(
              icon: Icons.credit_card,
              titre: 'Carte bancaire',
              sousTitre: 'Bientôt disponible',
              actif: false,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _moyen({
    required IconData icon,
    required String titre,
    required String sousTitre,
    required bool actif,
    VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: actif ? 1 : 0.5,
      child: InkWell(
        onTap: actif ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryDark),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titre,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                    Text(sousTitre,
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 12)),
                  ],
                ),
              ),
              if (actif)
                const Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _payerCredit(Devis devis) async {
    setState(() => _paying = true);
    final res = await DevisService.instance.payerAvecCredit(devis.id);
    if (!mounted) return;
    setState(() => _paying = false);

    switch (res) {
      case PaiementResultat.succes:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement effectué avec succès !'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
        break;
      case PaiementResultat.soldeInsuffisant:
        _dialogSoldeInsuffisant();
        break;
      case PaiementResultat.erreur:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le paiement a échoué. Réessayez.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }

  void _dialogSoldeInsuffisant() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Solde insuffisant'),
        content: const Text(
            'Votre crédit ne couvre pas ce montant. Rechargez votre compte pour continuer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WalletScreen()),
              );
            },
            child: const Text('Recharger'),
          ),
        ],
      ),
    );
  }

  Widget _buildLignes(Devis devis) {
    return Container(
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
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Prestations',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textDark)),
            ),
          ),
          ...List.generate(devis.lignes.length, (i) {
            final l = devis.lignes[i];
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${l.quantite}×',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(l.titre,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textDark)),
                      ),
                      const SizedBox(width: 8),
                      Text(Format.fcfa(l.sousTotal),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textDark)),
                    ],
                  ),
                ),
                if (i < devis.lignes.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRecap(Devis devis) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total à payer',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted)),
          Text(Format.fcfa(devis.total),
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
        ],
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
