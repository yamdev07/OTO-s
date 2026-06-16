import 'package:flutter/material.dart';

/// Palette centrale de l'application O'TO.
///
/// Ces couleurs étaient jusqu'ici dupliquées dans chaque écran
/// (`_primaryDark`, `_primary`, etc.). On les regroupe ici pour
/// garder une charte cohérente et faciliter les évolutions.
class AppColors {
  AppColors._();

  // Couleurs de marque
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primary = Color(0xFF3B82F6);

  // Fonds
  static const Color background = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  // États
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color indigo = Color(0xFF6366F1);

  // Textes
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  /// Dégradé de marque réutilisé sur les en-têtes.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
