import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/client_service.dart';
import '../utils/format.dart';
import 'prestations_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';

  static const _primaryDark = Color(0xFF1E3A8A);
  static const _primary = Color(0xFF3B82F6);

  static const _services = [
    {
      'title': 'Dépannage',
      'icon': Icons.emergency,
      'colors': [Color(0xFFEF4444), Color(0xFFDC2626)],
    },
    {
      'title': 'Réparation',
      'icon': Icons.build_rounded,
      'colors': [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    },
    {
      'title': 'Vidange',
      'icon': Icons.opacity,
      'colors': [Color(0xFF10B981), Color(0xFF059669)],
    },
    {
      'title': 'Lavage',
      'icon': Icons.local_car_wash,
      'colors': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    },
  ];

  static const _promos = [
    {
      'title': 'Révision complète',
      'subtitle': 'Jusqu\'à 40% de réduction',
      'badge': '-40%',
      'icon': Icons.car_repair,
      'colors': [Color(0xFFEF4444), Color(0xFFDC2626)],
    },
    {
      'title': 'Lavage premium',
      'subtitle': 'Offre spéciale du mois',
      'badge': '-20%',
      'icon': Icons.local_car_wash,
      'colors': [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    },
    {
      'title': 'Vidange express',
      'subtitle': 'Service rapide en 30 min',
      'badge': '-15%',
      'icon': Icons.opacity,
      'colors': [Color(0xFF10B981), Color(0xFF059669)],
    },
  ];

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

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité bientôt disponible'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openCatalogue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrestationsScreen()),
    );
  }

  /// Puce de solde dans l'en-tête, alimentée par le crédit réel du client.
  Widget _buildBalanceChip() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WalletScreen()),
      ),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ClientService.instance.watch(),
        builder: (context, snap) {
          final solde =
              (snap.data?.data()?['credit'] as num?)?.toDouble() ?? 0;
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  Format.fcfa(solde),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSectionTitle('Services rapides', padding: true),
                const SizedBox(height: 14),
                _buildServicesGrid(),
                const SizedBox(height: 28),
                _buildBanner(),
                const SizedBox(height: 28),
                _buildSectionTitle('Promotions', padding: true,
                    action: TextButton(
                      onPressed: _showComingSoon,
                      child: const Text('Tout voir',
                          style: TextStyle(color: _primary, fontWeight: FontWeight.w600)),
                    )),
                const SizedBox(height: 12),
                _buildPromosList(),
                const SizedBox(height: 28),
                _buildSectionTitle('Garages à proximité', padding: true,
                    action: TextButton(
                      onPressed: _showComingSoon,
                      child: const Text('Tout voir',
                          style: TextStyle(color: _primary, fontWeight: FontWeight.w600)),
                    )),
                const SizedBox(height: 12),
                _buildGaragesList(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 170,
      floating: false,
      pinned: true,
      backgroundColor: _primaryDark,
      elevation: 0,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.notifications_none, color: Colors.white, size: 22),
          ),
          onPressed: _showComingSoon,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryDark, _primary],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 16, 80, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _userName.isEmpty
                        ? 'Bonjour !'
                        : 'Bonjour, $_userName !',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
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

  Widget _buildSectionTitle(String title,
      {bool padding = false, Widget? action}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ? 20 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _services.map((s) {
          final colors = s['colors'] as List<Color>;
          return Expanded(
            child: GestureDetector(
              onTap: _openCatalogue,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(vertical: 18),
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
                      width: 52,
                      height: 52,
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
                      child: Icon(s['icon'] as IconData,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      s['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
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

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _openCatalogue,
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
                child: Icon(
                  Icons.directions_car,
                  size: 130,
                  color: Colors.white.withOpacity(0.1),
                ),
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
                      child: const Text(
                        'NOUVEAUTÉ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Service à domicile\nen un clic",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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

  Widget _buildPromosList() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _promos.length,
        itemBuilder: (context, i) {
          final p = _promos[i];
          final colors = p['colors'] as List<Color>;
          return GestureDetector(
            onTap: _showComingSoon,
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      p['icon'] as IconData,
                      size: 90,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            p['badge'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          p['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p['subtitle'] as String,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGaragesList() {
    final garages = [
      {
        'name': 'Garage Excellence',
        'rating': '4.9',
        'distance': '1.2 km',
        'open': true,
        'status': 'Ouvert maintenant',
        'colors': [_primaryDark, _primary],
      },
      {
        'name': 'Auto Service Pro',
        'rating': '4.5',
        'distance': '2.5 km',
        'open': false,
        'status': 'Ferme à 20h',
        'colors': [const Color(0xFF374151), const Color(0xFF6B7280)],
      },
      {
        'name': 'Mécano Express',
        'rating': '4.7',
        'distance': '3.8 km',
        'open': true,
        'status': 'Ouvert maintenant',
        'colors': [const Color(0xFF059669), const Color(0xFF10B981)],
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: garages.length,
      itemBuilder: (context, i) {
        final g = garages[i];
        final isOpen = g['open'] as bool;
        final colors = g['colors'] as List<Color>;
        return GestureDetector(
          onTap: _showComingSoon,
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      const Icon(Icons.car_repair, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Color(0xFFF59E0B), size: 13),
                                const SizedBox(width: 3),
                                Text(
                                  g['rating'] as String,
                                  style: const TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.location_on,
                              color: Colors.grey[400], size: 14),
                          const SizedBox(width: 2),
                          Text(
                            g['distance'] as String,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isOpen
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              g['status'] as String,
                              style: TextStyle(
                                color: isOpen
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFEF4444),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Color(0xFF94A3B8), size: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
