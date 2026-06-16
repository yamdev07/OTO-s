import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/vehicule_service.dart';
import '../theme/app_colors.dart';
import 'vehicule_form_screen.dart';

class VehiculeScreen extends StatelessWidget {
  const VehiculeScreen({super.key});

  void _openForm(BuildContext context,
      {String? id, Map<String, dynamic>? initial}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VehiculeFormScreen(vehiculeId: id, initial: initial),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String id, String label) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le véhicule'),
        content: Text('Voulez-vous vraiment supprimer "$label" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
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
      await VehiculeService.instance.supprimer(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Véhicule supprimé'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverFillRemaining(
            hasScrollBody: true,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: VehiculeService.instance.watch(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snap.hasError) return _buildErrorState();

                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) return _buildEmptyState(context);

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final v = docs[i].data();
                    return _buildVehicleCard(context, docs[i].id, v, i);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.primaryDark,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Mon Véhicule',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gérez vos véhicules enregistrés',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(
      BuildContext context, String id, Map<String, dynamic> v, int index) {
    final marque = v['marque'] as String? ?? 'À définir';
    final modele = v['modele'] as String? ?? 'À définir';
    final immat = v['immatriculation'] as String? ?? '';
    final motorisation = v['motorisation'] as String? ?? 'Non renseignée';
    final isPrincipal = v['principal'] == true;

    final colors = isPrincipal
        ? [AppColors.primaryDark, AppColors.primary]
        : [const Color(0xFF374151), const Color(0xFF6B7280)];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -10,
                  child: Icon(
                    Icons.directions_car,
                    size: 160,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 4,
                  child: _buildMenu(context, id, '$marque $modele', isPrincipal),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPrincipal)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 13),
                              SizedBox(width: 4),
                              Text('Principal',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Text(
                        '$marque $modele',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      if (immat.isNotEmpty)
                        Text(
                          immat,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow(Icons.car_rental, 'Marque', marque),
                const Divider(height: 20),
                _infoRow(Icons.directions_car_outlined, 'Modèle', modele),
                const Divider(height: 20),
                _infoRow(Icons.local_gas_station_outlined, 'Motorisation',
                    motorisation),
                const Divider(height: 20),
                _infoRow(Icons.confirmation_number_outlined, 'Immatriculation',
                    immat.isEmpty ? 'Non renseignée' : immat),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openForm(context, id: id, initial: v),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Modifier les informations'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      side: const BorderSide(color: AppColors.primaryDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(
      BuildContext context, String id, String label, bool isPrincipal) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) async {
        switch (value) {
          case 'principal':
            await VehiculeService.instance.definirPrincipal(id);
            break;
          case 'delete':
            await _confirmDelete(context, id, label);
            break;
        }
      },
      itemBuilder: (ctx) => [
        if (!isPrincipal)
          const PopupMenuItem(
            value: 'principal',
            child: Row(children: [
              Icon(Icons.star_outline, size: 18, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Définir comme principal'),
            ]),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
            SizedBox(width: 10),
            Text('Supprimer'),
          ]),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            child: const Icon(Icons.directions_car_outlined,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Aucun véhicule enregistré',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('Ajoutez votre véhicule pour commencer',
              style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un véhicule'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.danger, size: 48),
          SizedBox(height: 12),
          Text('Erreur de chargement'),
        ],
      ),
    );
  }
}
