import 'package:flutter/material.dart';
import '../models/service_category.dart';
import '../models/service_item.dart';

/// Catalogue O'TO SERVICE — le « noyau » de l'application.
///
/// Reprend les 8 catégories structurelles et leurs sous-catégories
/// décrites dans le cahier de charges (prestations de service). Les prix
/// sont en FCFA et constituent une grille indicative de référence.
class ServiceCatalog {
  ServiceCatalog._();

  static const List<ServiceCategory> categories = [
    ServiceCategory(
      id: 'lavage-nettoyage',
      nom: 'Lavage & Nettoyage',
      description: 'Lavage, nettoyage et rénovation esthétique',
      icon: Icons.local_car_wash,
      color: Color(0xFF3B82F6),
      items: [
        ServiceItem(
          id: 'lavage-int-ext',
          titre: 'Lavage intérieur et extérieur',
          prix: 2500,
          duree: '45 min',
        ),
        ServiceItem(
          id: 'nettoyage-sieges-tdb',
          titre: 'Nettoyage des sièges et tableau de bord',
          prix: 4000,
          duree: '1 h',
        ),
        ServiceItem(
          id: 'renovation-optiques',
          titre: 'Rénovation des optiques (phares)',
          prix: 6000,
          duree: '1 h',
        ),
        ServiceItem(
          id: 'traitement-anti-bacterien',
          titre: 'Traitement anti-bactérien',
          prix: 3500,
          duree: '30 min',
        ),
      ],
    ),
    ServiceCategory(
      id: 'pneumatique',
      nom: 'Pneumatique',
      description: 'Réparation, achat et montage de pneus',
      icon: Icons.tire_repair,
      color: Color(0xFF6366F1),
      items: [
        ServiceItem(
          id: 'reparation-crevaison',
          titre: 'Réparation crevaison pneu',
          prix: 1500,
          duree: '30 min',
        ),
        ServiceItem(
          id: 'pneu-achat-montage',
          titre: 'Pneu : achat et montage',
          prix: 17500,
          duree: '1 h',
        ),
        ServiceItem(
          id: 'montage-pneu',
          titre: 'Montage pneu',
          prix: 2000,
          duree: '30 min',
        ),
      ],
    ),
    ServiceCategory(
      id: 'climatisation',
      nom: 'Climatisation',
      description: 'Recharge, révision et diagnostic clim',
      icon: Icons.ac_unit,
      color: Color(0xFF06B6D4),
      items: [
        ServiceItem(
          id: 'recharge-clim',
          titre: 'Recharge clim',
          prix: 7500,
          duree: '45 min',
        ),
        ServiceItem(
          id: 'revision-clim',
          titre: 'Révision clim',
          prix: 9000,
          duree: '1 h',
        ),
        ServiceItem(
          id: 'diagnostic-clim',
          titre: 'Diagnostic clim',
          prix: 4000,
          duree: '30 min',
        ),
      ],
    ),
    ServiceCategory(
      id: 'revision-vidange',
      nom: 'Révision & Vidange',
      description: 'Vidange et révisions intermédiaires/générales',
      icon: Icons.opacity,
      color: Color(0xFF10B981),
      items: [
        ServiceItem(
          id: 'vidange',
          titre: 'Vidange',
          prix: 7500,
          duree: '30 min',
        ),
        ServiceItem(
          id: 'revision-intermediaire',
          titre: 'Révision intermédiaire (1 filtre + vidange + contrôle)',
          prix: 12500,
          duree: '1 h',
        ),
        ServiceItem(
          id: 'revision-generale',
          titre: 'Révision générale (3 filtres, bougies + vidange + contrôle)',
          prix: 22500,
          duree: '2 h',
        ),
        ServiceItem(
          id: 'revision-constructeur',
          titre: 'Révision constructeur (garantie préservée)',
          prix: 30000,
          duree: '2 h 30',
        ),
      ],
    ),
    ServiceCategory(
      id: 'freinage',
      nom: 'Freinage',
      description: 'Plaquettes, disques et liquide de frein',
      icon: Icons.disc_full,
      color: Color(0xFFEF4444),
      items: [
        ServiceItem(
          id: 'plaquettes-avant',
          titre: 'Remplacement plaquettes de frein avant',
          prix: 10000,
          duree: '1 h',
        ),
        ServiceItem(
          id: 'plaquettes-arriere',
          titre: 'Remplacement plaquettes de frein arrière',
          prix: 10000,
          duree: '1 h',
        ),
        ServiceItem(
          id: 'disque-plaquettes-avant',
          titre: 'Remplacement disque et plaquettes avant',
          prix: 19000,
          duree: '1 h 30',
        ),
        ServiceItem(
          id: 'disque-plaquettes-arriere',
          titre: 'Remplacement disque et plaquettes arrière',
          prix: 19000,
          duree: '1 h 30',
        ),
        ServiceItem(
          id: 'liquide-frein',
          titre: 'Remplacement de liquide de frein',
          prix: 6000,
          duree: '45 min',
        ),
        ServiceItem(
          id: 'kit-frein-machoire',
          titre: 'Remplacement kit de frein arrière (mâchoire)',
          prix: 15000,
          duree: '1 h 30',
        ),
        ServiceItem(
          id: 'kit-frein-tambour',
          titre: 'Remplacement kit de frein arrière (tambour)',
          prix: 16000,
          duree: '1 h 30',
        ),
      ],
    ),
    ServiceCategory(
      id: 'demarrage-charge',
      nom: 'Démarrage & Charge',
      description: 'Batterie, démarreur, alternateur',
      icon: Icons.battery_charging_full,
      color: Color(0xFFF59E0B),
      items: [
        ServiceItem(
          id: 'aide-demarrage',
          titre: 'Aide au démarrage (batterie déchargée)',
          prix: 4000,
          duree: 'Express',
        ),
        ServiceItem(
          id: 'remplacement-batterie',
          titre: 'Remplacement batterie',
          prix: 22500,
          duree: '30 min',
        ),
        ServiceItem(
          id: 'remplacement-bougie',
          titre: "Remplacement bougie d'allumage",
          prix: 6000,
          duree: '45 min',
        ),
        ServiceItem(
          id: 'remplacement-demarreur',
          titre: 'Remplacement démarreur',
          prix: 20000,
          duree: '2 h',
        ),
        ServiceItem(
          id: 'remplacement-alternateur',
          titre: 'Remplacement alternateur',
          prix: 25000,
          duree: '2 h',
        ),
        ServiceItem(
          id: 'controle-circuit-charge',
          titre: 'Contrôle de circuit de charge',
          prix: 3500,
          duree: '30 min',
        ),
      ],
    ),
    ServiceCategory(
      id: 'controle-diagnostic',
      nom: 'Contrôle & Diagnostic',
      description: 'Diagnostics sécurité et électronique',
      icon: Icons.electrical_services,
      color: Color(0xFF8B5CF6),
      items: [
        ServiceItem(
          id: 'diagnostic-securite',
          titre: 'Diagnostic sécurité',
          prix: 5000,
          duree: '45 min',
        ),
        ServiceItem(
          id: 'diagnostic-electronique',
          titre: 'Diagnostic électronique',
          prix: 5000,
          duree: '1 h',
        ),
        ServiceItem(
          id: 'pack-controle-technique',
          titre: 'Pack contrôle technique',
          prix: 9000,
          duree: '1 h 30',
        ),
      ],
    ),
    ServiceCategory(
      id: 'decalaminage',
      nom: 'Décalaminage moteur',
      description: 'Nettoyage carbone moteur',
      icon: Icons.cleaning_services,
      color: Color(0xFF0EA5E9),
      items: [
        ServiceItem(
          id: 'decalaminage-moteur',
          titre: 'Décalaminage moteur',
          prix: 11000,
          duree: '1 h',
        ),
      ],
    ),
  ];

  /// Nombre total de prestations disponibles.
  static int get totalPrestations =>
      categories.fold(0, (sum, c) => sum + c.items.length);

  /// Retrouve une catégorie par son id.
  static ServiceCategory? categorieParId(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Retrouve une prestation par son id, toutes catégories confondues.
  static ServiceItem? itemParId(String id) {
    for (final c in categories) {
      for (final item in c.items) {
        if (item.id == id) return item;
      }
    }
    return null;
  }
}
