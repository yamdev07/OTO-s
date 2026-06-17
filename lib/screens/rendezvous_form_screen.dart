import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/service_catalog.dart';
import '../services/rendezvous_service.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';

/// Prise de rendez-vous : date, créneau, prestation et adresse.
class RendezvousFormScreen extends StatefulWidget {
  /// Pré-remplissage optionnel (depuis un devis par ex.).
  final String? servicePrerempli;
  final String? devisId;

  const RendezvousFormScreen({super.key, this.servicePrerempli, this.devisId});

  @override
  State<RendezvousFormScreen> createState() => _RendezvousFormScreenState();
}

class _RendezvousFormScreenState extends State<RendezvousFormScreen> {
  final _adresse = TextEditingController();
  final _mapCtrl = MapController();
  DateTime? _date;
  TimeOfDay? _heure;
  String? _service;
  LatLng? _lieu;
  bool _saving = false;
  bool _locating = false;

  late final List<String> _services;

  @override
  void initState() {
    super.initState();
    _services = [
      'Dépannage',
      ...ServiceCatalog.categories.map((c) => c.nom),
    ];
    _service = widget.servicePrerempli ?? _services.first;
  }

  @override
  void dispose() {
    _adresse.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => _heure = t);
  }

  Future<void> _utiliserGps() async {
    setState(() => _locating = true);
    final pos = await LocationService.positionActuelle();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (pos != null) _lieu = pos;
    });
    if (pos != null) {
      _mapCtrl.move(pos, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'GPS indisponible ici (HTTP). Touchez la carte pour situer le lieu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmer() async {
    if (_date == null || _heure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisissez une date et un horaire'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final dt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _heure!.hour,
      _heure!.minute,
    );
    try {
      await RendezvousService.instance.prendre(
        date: dt,
        service: _service ?? 'Dépannage',
        adresse: _adresse.text.trim(),
        devisId: widget.devisId,
        lat: _lieu?.latitude,
        lng: _lieu?.longitude,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rendez-vous confirmé !'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Prendre rendez-vous',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _label('Prestation'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _service,
                isExpanded: true,
                items: _services
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _service = v),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _label('Date'),
          _pickerTile(
            icon: Icons.calendar_today_outlined,
            text: _date == null
                ? 'Choisir une date'
                : Format.dateCourte(_date!.toIso8601String()),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          _label('Horaire'),
          _pickerTile(
            icon: Icons.access_time,
            text: _heure == null
                ? 'Choisir un créneau'
                : _heure!.format(context),
            onTap: _pickTime,
          ),
          const SizedBox(height: 16),
          _label('Adresse d\'intervention'),
          TextField(
            controller: _adresse,
            decoration: InputDecoration(
              hintText: 'Ex: Quartier, rue, repère...',
              hintStyle:
                  const TextStyle(color: AppColors.textLight, fontSize: 14),
              prefixIcon: const Icon(Icons.location_on_outlined,
                  color: Color(0xFF6B7280), size: 20),
              filled: true,
              fillColor: AppColors.surfaceAlt,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label('Lieu d\'intervention sur la carte'),
              TextButton.icon(
                onPressed: _locating ? null : _utiliserGps,
                icon: _locating
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, size: 16),
                label: const Text('Ma position'),
              ),
            ],
          ),
          _buildMap(),
          const SizedBox(height: 6),
          Text(
            _lieu == null
                ? 'Touchez la carte pour placer le repère du lieu.'
                : 'Lieu défini : ${_lieu!.latitude.toStringAsFixed(5)}, ${_lieu!.longitude.toStringAsFixed(5)}',
            style: const TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _confirmer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Confirmer le rendez-vous',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: _lieu ?? LocationService.defautCotonou,
            initialZoom: 13,
            onTap: (_, latlng) => setState(() => _lieu = latlng),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.otoservice.app',
            ),
            if (_lieu != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _lieu!,
                    width: 44,
                    height: 44,
                    child: const Icon(Icons.location_on,
                        color: AppColors.danger, size: 44),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF475569))),
      );

  Widget _pickerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6B7280), size: 20),
            const SizedBox(width: 12),
            Text(text,
                style: const TextStyle(
                    color: AppColors.textDark, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
