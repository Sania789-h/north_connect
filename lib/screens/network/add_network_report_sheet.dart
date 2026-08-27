import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/network_model.dart';
import '../../services/network_service.dart';

class AddNetworkReportSheet extends StatefulWidget {
  const AddNetworkReportSheet({super.key});

  @override
  State<AddNetworkReportSheet> createState() => _AddNetworkReportSheetState();
}

class _AddNetworkReportSheetState extends State<AddNetworkReportSheet> {
  final _formKey = GlobalKey<FormState>();
  final _locationCtrl = TextEditingController(text: 'Gilgit City');
  final _descCtrl = TextEditingController();

  static const List<String> _carriers = ['SCOM', 'Jazz', 'Zong 4G', 'Telenor', 'Ufone'];
  static const List<String> _statuses = ['Good', 'Fair', 'Poor', 'No Signal'];
  static const List<String> _signals = ['Strong (4G)', 'Moderate (3G)', 'Weak (2G)', 'No Signal'];

  String _selectedCarrier = _carriers[0];
  String _selectedStatus = _statuses[0];
  String _selectedSignal = _signals[0];
  bool _submitting = false;

  @override
  void dispose() {
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _submitting = true);

    try {
      final report = await NetworkService.submitNetworkReport(
        location: _locationCtrl.text.trim(),
        networkType: _selectedCarrier,
        networkStatus: _selectedStatus,
        signalStrength: _selectedSignal,
        description: _descCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop<NetworkModel>(context, report);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit report: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF111827) : Colors.white;
    final handleColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final labelColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A);
    final inputFill = isDark ? const Color(0xFF0F1C2E) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0);
    final chipBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.94,
        expand: false,
        builder: (_, scrollCtrl) {
          return Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Container(
                    width: 46,
                    height: 4,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _submitting ? null : () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                      Expanded(
                        child: Text(
                          'Submit Network Report',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Divider(height: 1, color: borderColor),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Network Carrier', labelColor),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _carriers.map((carrier) {
                              final sel = _selectedCarrier == carrier;
                              return ChoiceChip(
                                label: Text(carrier),
                                selected: sel,
                                selectedColor: const Color(0xFF22C55E),
                                backgroundColor: chipBg,
                                labelStyle: GoogleFonts.outfit(
                                  color: sel ? Colors.white : labelColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (_) {
                                  setState(() => _selectedCarrier = carrier);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),

                          _label('Location / Area', labelColor),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _locationCtrl,
                            style: GoogleFonts.outfit(color: titleColor),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter location' : null,
                            decoration: InputDecoration(
                              hintText: 'e.g. Aliabad, Hunza',
                              hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: inputFill,
                              prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFF22C55E)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                            ),
                          ),
                          const SizedBox(height: 18),

                          _label('Network Status', labelColor),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _statuses.map((st) {
                              final sel = _selectedStatus == st;
                              final isGood = st == 'Good';
                              final isFair = st == 'Fair';
                              final color = isGood ? const Color(0xFF22C55E) : isFair ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
                              return ChoiceChip(
                                label: Text(st),
                                selected: sel,
                                selectedColor: color,
                                backgroundColor: chipBg,
                                labelStyle: GoogleFonts.outfit(
                                  color: sel ? Colors.white : labelColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (_) {
                                  setState(() => _selectedStatus = st);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),

                          _label('Signal Strength', labelColor),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _signals.map((sig) {
                              final sel = _selectedSignal == sig;
                              return ChoiceChip(
                                label: Text(sig),
                                selected: sel,
                                selectedColor: const Color(0xFF3B82F6),
                                backgroundColor: chipBg,
                                labelStyle: GoogleFonts.outfit(
                                  color: sel ? Colors.white : labelColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (_) {
                                  setState(() => _selectedSignal = sig);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),

                          _label('Description / Status Details', labelColor),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descCtrl,
                            maxLines: 3,
                            style: GoogleFonts.outfit(color: titleColor),
                            validator: (v) => (v == null || v.trim().length < 5) ? 'Enter at least 5 characters' : null,
                            decoration: InputDecoration(
                              hintText: 'Describe current internet/calling performance or outages...',
                              hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: inputFill,
                              prefixIcon: const Icon(Icons.notes_rounded, color: Color(0xFF3B82F6)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _submitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF067A46),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: _submitting
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.send_rounded, size: 18),
                              label: Text(
                                _submitting ? 'Submitting...' : 'Submit Report',
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
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

  Widget _label(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: color),
    );
  }
}
