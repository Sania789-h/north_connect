import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/alert_model.dart';

class AddAlertSheet extends StatefulWidget {
  const AddAlertSheet({super.key});

  @override
  State<AddAlertSheet> createState() => _AddAlertSheetState();
}

class _AddAlertSheetState extends State<AddAlertSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController(text: 'Gilgit, Pakistan');

  static const List<_CatDef> _categories = [
    _CatDef('Emergency Alert', Color(0xFFDC2626), Icons.warning_amber_rounded),
    _CatDef('Weather', Color(0xFF0EA5E9), Icons.wb_cloudy_rounded),
    _CatDef('Road Alert', Color(0xFFF97316), Icons.directions_car_rounded),
    _CatDef('Network', Color(0xFF6366F1), Icons.signal_cellular_alt_rounded),
    _CatDef('SOS', Color(0xFFE11D48), Icons.sos_rounded),
  ];

  static const List<_SevDef> _severities = [
    _SevDef('Low', Color(0xFF22C55E), Color(0xFF86EFAC)),
    _SevDef('Medium', Color(0xFFF59E0B), Color(0xFFFCD34D)),
    _SevDef('High', Color(0xFFEF4444), Color(0xFFFCA5A5)),
  ];

  String _selectedCategory = _categories[0].label;
  String _selectedSeverity = _severities[1].label;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  InputDecoration _deco(String label, String hint, IconData icon) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: GoogleFonts.outfit(
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
        errorStyle: GoogleFonts.outfit(
          fontSize: 12,
          color: const Color(0xFFDC2626),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF067A46),
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _submitting = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
      final alert = AlertModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _selectedCategory,
        location: _locationCtrl.text.trim(),
        severity: _selectedSeverity,
        createdAt: DateTime.now(),
        isRead: false,
      );
      Navigator.pop<AlertModel>(context, alert);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.94,
        expand: false,
        builder: (_, scrollCtrl) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Container(
                    width: 46,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.pop(context),
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Add Alert',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('Alert Category'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _categories.map((c) {
                              final selected = _selectedCategory == c.label;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedCategory = c.label);
                                },
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 160),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? c.color.withValues(alpha: 0.12)
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selected
                                          ? c.color
                                          : const Color(0xFFE2E8F0),
                                      width: selected ? 1.4 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? c.color
                                              : c.color
                                                  .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(9),
                                        ),
                                        child: Icon(
                                          c.icon,
                                          size: 16,
                                          color: selected
                                              ? Colors.white
                                              : c.color,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        c.label,
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: selected
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          _sectionLabel('Alert Title'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleCtrl,
                            textCapitalization: TextCapitalization.sentences,
                            validator: (v) {
                              if (v == null || v.trim().length < 4) {
                                return 'Title must be at least 4 characters.';
                              }
                              return null;
                            },
                            decoration: _deco(
                              'Title',
                              'e.g. Heavy rain expected in upper areas',
                              Icons.title_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _sectionLabel('Description'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descCtrl,
                            maxLines: 4,
                            minLines: 3,
                            textCapitalization:
                                TextCapitalization.sentences,
                            validator: (v) {
                              if (v == null || v.trim().length < 10) {
                                return 'Description should be at least 10 characters.';
                              }
                              return null;
                            },
                            decoration: _deco(
                              'Describe the alert',
                              'What happened, where exactly, and any safety advice.',
                              Icons.notes_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _sectionLabel('Location'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _locationCtrl,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter a location.';
                              }
                              return null;
                            },
                            decoration: _deco(
                              'Location',
                              'e.g. Skardu Road, near Junction 3',
                              Icons.location_on_rounded,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _sectionLabel('Severity'),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: _severities.map((s) {
                                final selected = _selectedSeverity == s.label;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() =>
                                          _selectedSeverity = s.label);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 160),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 11),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: selected
                                            ? Border.all(color: s.color)
                                            : null,
                                        boxShadow: selected
                                            ? [
                                                BoxShadow(
                                                  color: s.color.withValues(
                                                      alpha: 0.15),
                                                  blurRadius: 8,
                                                  offset:
                                                      const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: s.color,
                                              shape: BoxShape.circle,
                                              boxShadow: selected
                                                  ? [
                                                      BoxShadow(
                                                        color: s.light,
                                                        blurRadius: 6,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 7),
                                          Text(
                                            s.label,
                                            style: GoogleFonts.outfit(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: selected
                                                  ? s.color
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _submitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF067A46),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: _submitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded, size: 18),
                              label: Text(
                                _submitting ? 'Adding...' : 'Publish Alert',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      );
}

class _CatDef {
  final String label;
  final Color color;
  final IconData icon;
  const _CatDef(this.label, this.color, this.icon);
}

class _SevDef {
  final String label;
  final Color color;
  final Color light;
  const _SevDef(this.label, this.color, this.light);
}
