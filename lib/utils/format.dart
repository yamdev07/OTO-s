/// Helpers de formatage partagés.
class Format {
  Format._();

  /// Formate un montant en FCFA avec séparateur de milliers.
  ///
  /// Exemple : `15000` -> `15 000 FCFA`.
  static String fcfa(num montant) {
    final entier = montant.round();
    final chiffres = entier.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < chiffres.length; i++) {
      if (i > 0 && (chiffres.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(chiffres[i]);
    }
    final signe = entier < 0 ? '-' : '';
    return '$signe${buffer.toString()} FCFA';
  }

  /// Formate une date ISO (`DateTime.toIso8601String`) en `jj/mm/aaaa`.
  static String dateCourte(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    final jj = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$jj/$mm/${d.year}';
  }

  /// Formate une date+heure en `jj/mm/aaaa à HHhMM`.
  static String dateHeure(DateTime d) {
    final jj = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$jj/$mm/${d.year} à ${hh}h$min';
  }
}
