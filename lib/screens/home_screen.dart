import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _mainServices = [
    {
      'title': 'Dépannage',
      'icon': Icons.emergency,
      'route': '/urgence',
      'gradient': [Color(0xFFEF5350), Color(0xFFE53935)],
    },
    {
      'title': 'Réparation',
      'icon': Icons.build_rounded,
      'route': '/reparation',
      'gradient': [Color(0xFF42A5F5), Color(0xFF1E88E5)],
    },
    {
      'title': 'Vidange',
      'icon': Icons.opacity,
      'route': '/vidange',
      'gradient': [Color(0xFF66BB6A), Color(0xFF43A047)],
    },
    {
      'title': 'Lavage',
      'icon': Icons.local_car_wash,
      'route': '/lavage',
      'gradient': [Color(0xFFAB47BC), Color(0xFF8E24AA)],
    },
  ];

  final List<Map<String, dynamic>> _promotions = [
    {
      'title': 'Révision complète',
      'subtitle': 'Jusqu\'à 40% de réduction',
      'image': 'assets/promo1.jpg',
      'route': '/promo-revision',
      'badge': '-40%',
      'color': Color(0xFFEF5350),
    },
    {
      'title': 'Lavage premium',
      'subtitle': 'Offre spéciale du mois',
      'image': 'assets/promo2.jpg',
      'route': '/promo-lavage',
      'badge': '-20%',
      'color': Color(0xFF42A5F5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // AppBar moderne avec effet
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E3A8A),
                      Color(0xFF3B82F6),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Bonjour 👋",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Client O'TO",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.account_balance_wallet,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "25 000",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    " FCFA",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_none, color: Colors.white, size: 22),
                ),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              SizedBox(width: 8),
            ],
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),

                // Services rapides
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Services rapides",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                
                // Grille de services
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _mainServices.map((service) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, service['route']),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 6),
                            padding: EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: List<Color>.from(service['gradient']),
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: service['gradient'][0].withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    service['icon'],
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  service['title'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF1F2937),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 28),

                // Bannière promotionnelle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6366F1),
                          Color(0xFF8B5CF6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            Icons.directions_car,
                            size: 140,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "NOUVEAUTÉ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Service à domicile\nen un clic",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Réservez maintenant",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 28),

                // Promotions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Promotions",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/promotions'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Tout voir",
                              style: TextStyle(
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF3B82F6)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 12),

                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _promotions.length,
                    itemBuilder: (context, index) {
                      final promo = _promotions[index];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, promo['route']),
                        child: Container(
                          width: size.width * 0.75,
                          margin: EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  promo['image'],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: promo['color'],
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: promo['color'].withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    promo['badge'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      promo['title'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      promo['subtitle'],
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
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
                ),

                SizedBox(height: 28),

                // Garages à proximité
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Garages près de vous",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/garages'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Tout voir",
                              style: TextStyle(
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF3B82F6)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                // Liste des garages
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pushNamed(context, '/garage-details'),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/garage${index + 1}.jpg',
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      index == 0 ? "Garage Excellence" : "Auto Service Pro",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                                              SizedBox(width: 4),
                                              Text(
                                                index == 0 ? "4.9" : "4.5",
                                                style: TextStyle(
                                                  color: Color(0xFFF59E0B),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Icon(Icons.location_on, color: Color(0xFF9CA3AF), size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          index == 0 ? "1.2 km" : "2.5 km",
                                          style: TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: index == 0 ? Color(0xFFD1FAE5) : Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: index == 0 ? Color(0xFF10B981) : Color(0xFFEF4444),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            index == 0 ? "Ouvert maintenant" : "Ferme à 20h",
                                            style: TextStyle(
                                              color: index == 0 ? Color(0xFF10B981) : Color(0xFFEF4444),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, color: Color(0xFF9CA3AF), size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}