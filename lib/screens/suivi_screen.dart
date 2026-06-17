import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';
import '../theme/app_colors.dart';

/// Suivi en temps réel de l'arrivée du garage mobile vers le lieu du RDV.
///
/// Le déplacement du garage est simulé côté client (interpolation), prêt
/// à être remplacé par un flux Firestore de la position réelle du
/// prestataire (espace O'TO PRO) le moment venu.
class SuiviScreen extends StatefulWidget {
  final String service;
  final double? lat;
  final double? lng;

  const SuiviScreen({
    super.key,
    required this.service,
    this.lat,
    this.lng,
  });

  @override
  State<SuiviScreen> createState() => _SuiviScreenState();
}

class _SuiviScreenState extends State<SuiviScreen> {
  final _mapCtrl = MapController();
  static const _distance = Distance();

  late final LatLng _destination;
  late final LatLng _depart;
  late LatLng _garage;

  Timer? _timer;
  double _t = 0; // progression 0 -> 1
  static const _dureeSecondes = 24; // arrivée simulée en ~24 s
  static const _pas = 0.03; // incrément par tick

  @override
  void initState() {
    super.initState();
    _destination = (widget.lat != null && widget.lng != null)
        ? LatLng(widget.lat!, widget.lng!)
        : LocationService.defautCotonou;
    // Le garage démarre à ~3 km au nord-est du lieu d'intervention.
    _depart = LatLng(
      _destination.latitude + 0.028,
      _destination.longitude + 0.022,
    );
    _garage = _depart;
    _timer = Timer.periodic(const Duration(milliseconds: 700), _tick);
  }

  void _tick(Timer timer) {
    if (!mounted) return;
    setState(() {
      _t = (_t + _pas).clamp(0.0, 1.0);
      _garage = LatLng(
        _depart.latitude + (_destination.latitude - _depart.latitude) * _t,
        _depart.longitude + (_destination.longitude - _depart.longitude) * _t,
      );
    });
    _mapCtrl.move(_garage, _mapCtrl.camera.zoom);
    if (_t >= 1.0) timer.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get _metresRestants =>
      _distance.as(LengthUnit.Meter, _garage, _destination);

  String get _etaTexte {
    if (_t >= 1.0) return 'Arrivé';
    final secondes = ((1 - _t) * _dureeSecondes).round();
    if (secondes >= 60) {
      final min = (secondes / 60).ceil();
      return '~$min min';
    }
    return '~$secondes s';
  }

  String get _distanceTexte {
    final m = _metresRestants;
    if (m >= 1000) return '${(m / 1000).toStringAsFixed(1)} km';
    return '${m.round()} m';
  }

  bool get _arrive => _t >= 1.0;

  @override
  Widget build(BuildContext context) {
    final centre = LatLng(
      (_depart.latitude + _destination.latitude) / 2,
      (_depart.longitude + _destination.longitude) / 2,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suivi du garage',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: centre,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.otoservice.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_garage, _destination],
                    strokeWidth: 4,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _destination,
                    width: 44,
                    height: 44,
                    child: const Icon(Icons.location_on,
                        color: AppColors.danger, size: 44),
                  ),
                  Marker(
                    point: _garage,
                    width: 46,
                    height: 46,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_shipping,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildStatusCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (_arrive ? AppColors.success : AppColors.primary)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _arrive ? Icons.check_circle : Icons.local_shipping,
                  color: _arrive ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _arrive
                          ? 'Le garage est arrivé !'
                          : 'Votre garage mobile arrive',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.service,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _stat(Icons.straighten, 'Distance', _distanceTexte),
              ),
              Container(width: 1, height: 36, color: AppColors.border),
              Expanded(
                child: _stat(Icons.schedule, 'Arrivée estimée', _etaTexte),
              ),
            ],
          ),
          if (!_arrive) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _t,
                minHeight: 6,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textLight, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark)),
        Text(label,
            style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
      ],
    );
  }
}
