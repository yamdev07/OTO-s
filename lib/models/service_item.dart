/// Une prestation (sous-catégorie) du catalogue O'TO SERVICE.
class ServiceItem {
  /// Identifiant stable (kebab-case), utilisé comme clé de panier.
  final String id;
  final String titre;
  final double prix;
  final String duree;

  const ServiceItem({
    required this.id,
    required this.titre,
    required this.prix,
    required this.duree,
  });
}
