import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Accès à la position GPS de l'appareil (best-effort).
///
/// Sur le web, l'API de géolocalisation du navigateur n'est disponible
/// qu'en contexte sécurisé (HTTPS ou localhost). En cas d'échec ou de
/// refus, on retourne `null` et l'appelant propose un repli
/// (toucher la carte, ou centre par défaut).
class LocationService {
  LocationService._();

  /// Position par défaut : Cotonou (Bénin).
  static const LatLng defautCotonou = LatLng(6.3703, 2.3912);

  /// Tente de récupérer la position actuelle. `null` si indisponible.
  static Future<LatLng?> positionActuelle() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }
}
