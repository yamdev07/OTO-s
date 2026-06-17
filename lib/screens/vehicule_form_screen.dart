import 'package:flutter/material.dart';

import '../services/vehicule_service.dart';
import '../theme/app_colors.dart';

/// Formulaire d'ajout / édition d'un véhicule.
/// (marque, modèle, motorisation, immatriculation — cf. cahier de charges)
class VehiculeFormScreen extends StatefulWidget {
  /// Id du véhicule à éditer, ou `null` pour une création.
  final String? vehiculeId;
  final Map<String, dynamic>? initial;

  const VehiculeFormScreen({super.key, this.vehiculeId, this.initial});

  bool get isEdition => vehiculeId != null;

  @override
  State<VehiculeFormScreen> createState() => _VehiculeFormScreenState();
}

class _VehiculeFormScreenState extends State<VehiculeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _marque;
  late final TextEditingController _modele;
  late final TextEditingController _immat;
  String _motorisation = 'Essence';
  bool _principal = false;
  bool _saving = false;

  static const _motorisations = [
    'Essence',
    'Diesel',
    'Hybride',
    'Électrique',
    'GPL',
  ];

  @override
  void initState() {
    super.initState();
    final i = widget.initial ?? {};
    _marque = TextEditingController(text: i['marque'] as String? ?? '');
    _modele = TextEditingController(text: i['modele'] as String? ?? '');
    _immat =
        TextEditingController(text: i['immatriculation'] as String? ?? '');
    final mot = i['motorisation'] as String?;
    if (mot != null && _motorisations.contains(mot)) _motorisation = mot;
    _principal = i['principal'] == true;
  }

  @override
  void dispose() {
    _marque.dispose();
    _modele.dispose();
    _immat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = {
      'marque': _marque.text.trim(),
      'modele': _modele.text.trim(),
      'immatriculation': _immat.text.trim().toUpperCase(),
      'motorisation': _motorisation,
      'principal': _principal,
    };
    try {
      if (widget.isEdition) {
        await VehiculeService.instance.modifier(widget.vehiculeId!, data);
      } else {
        await VehiculeService.instance.ajouter(data);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdition
              ? 'Véhicule mis à jour'
              : 'Véhicule ajouté'),
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
        title: Text(widget.isEdition ? 'Modifier le véhicule' : 'Nouveau véhicule',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _label('Marque'),
            _field(_marque, 'Ex: Toyota', Icons.car_rental,
                requis: true),
            const SizedBox(height: 16),
            _label('Modèle'),
            _field(_modele, 'Ex: Corolla', Icons.directions_car_outlined,
                requis: true),
            const SizedBox(height: 16),
            _label('Immatriculation'),
            _field(_immat, 'Ex: AB-123-CD',
                Icons.confirmation_number_outlined),
            const SizedBox(height: 16),
            _label('Type de motorisation'),
            _buildMotorisation(),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _principal,
              onChanged: (v) => setState(() => _principal = v),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: const Text('Véhicule principal',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              subtitle: const Text('Utilisé par défaut pour les devis',
                  style: TextStyle(color: AppColors.textLight, fontSize: 12)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
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
                    : Text(
                        widget.isEdition ? 'Enregistrer' : 'Ajouter le véhicule',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
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

  Widget _field(TextEditingController c, String hint, IconData icon,
      {bool requis = false}) {
    return TextFormField(
      controller: c,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
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
      validator: requis
          ? (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null
          : null,
    );
  }

  Widget _buildMotorisation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _motorisation,
          isExpanded: true,
          items: _motorisations
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (v) => setState(() => _motorisation = v ?? _motorisation),
        ),
      ),
    );
  }
}
