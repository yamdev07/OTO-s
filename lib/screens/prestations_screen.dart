import 'package:flutter/material.dart';

import '../data/service_catalog.dart';
import '../models/cart_item.dart';
import '../models/service_category.dart';
import '../services/panier_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import 'category_detail_screen.dart';
import 'panier_screen.dart';

/// Catalogue O'TO SERVICE : grille des catégories structurelles.
/// L'utilisateur choisit une catégorie puis une sous-catégorie (prestation).
class PrestationsScreen extends StatelessWidget {
  const PrestationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) =>
                    _buildCategoryCard(context, ServiceCatalog.categories[i]),
                childCount: ServiceCatalog.categories.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.88,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [_buildCartButton(context)],
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
                    'O\'TO Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ServiceCatalog.totalPrestations} prestations · ${ServiceCatalog.categories.length} catégories',
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

  /// Bouton panier avec badge du nombre d'articles (temps réel).
  Widget _buildCartButton(BuildContext context) {
    return StreamBuilder<List<CartItem>>(
      stream: PanierService.instance.watch(),
      builder: (context, snap) {
        final count = (snap.data ?? [])
            .fold<int>(0, (acc, e) => acc + e.quantite);
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined,
                  color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PanierScreen()),
              ),
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, ServiceCategory cat) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDetailScreen(category: cat),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cat.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(cat.icon, color: cat.color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                cat.nom,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cat.description,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'dès ${Format.fcfa(cat.prixMin)}',
                    style: TextStyle(
                      color: cat.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 13, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
