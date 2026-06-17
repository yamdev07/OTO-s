import 'package:flutter/material.dart';
import 'service_item.dart';

/// Une catégorie structurelle du catalogue O'TO SERVICE
/// (lavage, pneumatique, freinage, ...).
class ServiceCategory {
  final String id;
  final String nom;
  final String description;
  final IconData icon;
  final Color color;
  final List<ServiceItem> items;

  const ServiceCategory({
    required this.id,
    required this.nom,
    required this.description,
    required this.icon,
    required this.color,
    required this.items,
  });

  /// Prix d'entrée de gamme affiché ("à partir de").
  double get prixMin =>
      items.map((e) => e.prix).reduce((a, b) => a < b ? a : b);
}
