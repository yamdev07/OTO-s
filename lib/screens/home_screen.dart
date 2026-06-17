import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/service_catalog.dart';
import '../models/service_category.dart';
import '../services/client_service.dart';
import '../services/rendezvous_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import 'prestations_screen.dart';
import 'category_detail_screen.dart';
import 'devis_screen.dart';
import 'wallet_screen.dart';
import 'rendezvous_screen.dart';
import 'rendezvous_form_screen.dart';
import 'suivi_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(uid)
          .get();
      if (doc.exists && mounted) {
        final prenom = doc['prenom'] as String? ?? '';
        final nom = doc['nom'] as String? ?? '';
        setState(() => _userName = prenom.isNotEmpty ? prenom : nom);
      }
    } catch (_) {}
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildProchainRdv(),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  'Catégories de services',
                  action: TextButton(
                    onPressed: () => _push(const PrestationsScreen()),
                    child: const Text('Tout voir',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategories(),
                const SizedBox(height: 24),
                _buildPromoBanner(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- AppBar

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 175,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none,
                color: Colors.white, size: 22),
          ),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune nouvelle notification'),
              behavior: SnackBarBehavior.floating,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _userName.isEmpty ? 'Bonjour !' : 'Bonjour, $_userName !',
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Que faire aujourd'hui ?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildBalanceChip(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceChip() {
    return GestureDetector(
      onTap: () => _push(const WalletScreen()),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ClientService.instance.watch(),
        builder: (context, snap) {
          final solde =
              (snap.data?.data()?['credit'] as num?)?.toDouble() ?? 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Solde : ${Format.fcfa(solde)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------- Actions rapides

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.build_rounded,
        'label': 'Catalogue',
        'colors': [AppColors.primary, AppColors.primaryDark],
        'onTap': () => _push(const PrestationsScreen()),
      },
      {
        'icon': Icons.event_available,
        'label': 'Rendez-vous',
        'colors': [const Color(0xFF10B981), const Color(0xFF059669)],
        'onTap': () => _push(const RendezvousScreen()),
      },
      {
        'icon': Icons.request_quote,
        'label': 'Mes devis',
        'colors': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        'onTap': () => _push(const DevisScreen()),
      },
      {
        'icon': Icons.account_balance_wallet,
        'label': 'Crédit',
        'colors': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
        'onTap': () => _push(const WalletScreen()),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: actions.map((a) {
          final colors = a['colors'] as List<Color>;
          return Expanded(
            child: GestureDetector(
              onTap: a['onTap'] as VoidCallback,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: colors[0].withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(a['icon'] as IconData,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      a['label'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ------------------------------------------------------------ Prochain RDV

  Widget _buildProchainRdv() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: RendezvousService.instance.watchClient(),
        builder: (context, snap) {
          final now = DateTime.now();
          final futurs = (snap.data?.docs ?? [])
              .where((d) {
                final data = d.data();
                final date = DateTime.tryParse(data['date'] as String? ?? '');
                return data['statut'] == 'planifié' &&
                    date != null &&
                    date.isAfter(now);
              })
              .toList()
            ..sort((a, b) => (a.data()['date'] as String)
                .compareTo(b.data()['date'] as String));

          if (futurs.isEmpty) return _buildNoRdvCard();
          return _buildRdvCard(futurs.first.data());
        },
      ),
    );
  }

  Widget _buildNoRdvCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_busy, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aucun rendez-vous à venir',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark)),
                SizedBox(height: 2),
                Text('Planifiez une intervention à domicile',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _push(const RendezvousFormScreen()),
            child: const Text('Prendre RDV',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRdvCard(Map<String, dynamic> rdv) {
    final date = DateTime.tryParse(rdv['date'] as String? ?? '');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('PROCHAIN RENDEZ-VOUS',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rdv['service'] as String? ?? 'Intervention',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (date != null)
            Text(
              Format.dateHeure(date),
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9), fontSize: 13),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _push(SuiviScreen(
                service: rdv['service'] as String? ?? 'Intervention',
                lat: (rdv['lat'] as num?)?.toDouble(),
                lng: (rdv['lng'] as num?)?.toDouble(),
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.navigation_outlined, size: 18),
              label: const Text('Suivre le garage',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- Catégories

  Widget _buildCategories() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: ServiceCatalog.categories.length,
        itemBuilder: (context, i) {
          final cat = ServiceCatalog.categories[i];
          return _buildCategoryChip(cat);
        },
      ),
    );
  }

  Widget _buildCategoryChip(ServiceCategory cat) {
    return GestureDetector(
      onTap: () => _push(CategoryDetailScreen(category: cat)),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(cat.icon, color: cat.color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              cat.nom,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- Promo banner

  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _push(const PrestationsScreen()),
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: -10,
                child: Icon(Icons.car_repair,
                    size: 130, color: Colors.white.withOpacity(0.12)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('JUSQU\'À -40%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          )),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Révision complète\nà prix réduit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- Helpers

  Widget _buildSectionTitle(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              )),
          if (action != null) action,
        ],
      ),
    );
  }
}
