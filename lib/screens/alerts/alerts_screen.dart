import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/helpers.dart';
import '../../models/alert_model.dart';
import '../../widgets/alert_card.dart';
import '../../services/mock_database_service.dart';
import 'alert_details_screen.dart';
import 'add_alert_sheet.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  static const List<String> _kFilters = [
    'All',
    'Weather',
    'Road',
    'Safety',
    'Network',
    'SOS',
  ];
  String _selectedFilter = 'All';
  Key _refreshKey = UniqueKey();
  bool _creating = false;

  Future<List<AlertModel>> _getAlerts() async {
    try {
      final data = await Supabase.instance.client
          .from('alerts')
          .select()
          .order('created_at', ascending: false);

      final dbAlerts = List<Map<String, dynamic>>.from(data)
          .map((row) => AlertModel.fromMap(row))
          .toList();

      final localAlerts = MockDatabaseService.alerts;
      final Set<String> existingIds = dbAlerts.map((a) => a.id ?? '').toSet();

      final combined = <AlertModel>[];
      combined.addAll(localAlerts.where((a) => a.id != null && !existingIds.contains(a.id)));
      combined.addAll(dbAlerts);

      combined.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.now();
        final dateB = b.createdAt ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      return combined;
    } catch (e) {
      debugPrint("Supabase alerts query failed, using offline fallback: $e");
      return MockDatabaseService.alerts;
    }
  }

  List<AlertModel> _filterAlerts(List<AlertModel> alerts) {
    if (_selectedFilter == 'All') return alerts;
    final filter = _selectedFilter.toLowerCase();
    return alerts.where((a) {
      final cat = a.category.toLowerCase();
      final title = a.title.toLowerCase();
      return cat == filter ||
          cat.contains(filter) ||
          title.contains(filter);
    }).toList();
  }

  Future<void> _handleCreateAlert() async {
    if (_creating) return;
    setState(() => _creating = true);
    HapticFeedback.lightImpact();
    try {
      final created = await showModalBottomSheet<AlertModel>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        useSafeArea: true,
        builder: (_) => const AddAlertSheet(),
      );

      if (created == null) return;

      AlertModel saved = created;
      try {
        final insertMap = saved.toMap()..remove('id');
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) insertMap['user_id'] = userId;
        final inserted = await Supabase.instance.client
            .from('alerts')
            .insert(insertMap)
            .select()
            .maybeSingle();
        if (inserted != null) {
          saved = AlertModel.fromMap(
            Map<String, dynamic>.from(inserted as Map),
          );
        } else {
          MockDatabaseService.addAlert(saved);
        }
      } catch (e) {
        debugPrint('Supabase create alert failed: $e');
        MockDatabaseService.addAlert(saved);
      }

      if (!mounted) return;
      Helpers.showSnackBar(context, 'Alert added successfully.');
      setState(() {
        _refreshKey = UniqueKey();
        _selectedFilter = 'All';
      });
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final tertiaryText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);
    final filterBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final emptyIconBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final iconColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _creating ? null : _handleCreateAlert,
        backgroundColor: const Color(0xFF067A46),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        icon: _creating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Add Alert',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Alerts',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 42),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_kFilters.length, (i) {
                    final f = _kFilters[i];
                    final selected = _selectedFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedFilter = f);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF067A46)
                                : filterBg,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF067A46)
                                          .withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            f,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  setState(() => _refreshKey = UniqueKey());
                },
                color: const Color(0xFF067A46),
                child: FutureBuilder<List<AlertModel>>(
                  key: _refreshKey,
                  future: _getAlerts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF067A46),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return ListView(
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: emptyIconBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.notifications_none_rounded,
                                    color: textSecondary,
                                    size: 34,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'No Alerts Available',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap "Add Alert" to create your first alert.',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: tertiaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    final filtered = _filterAlerts(snapshot.data!);

                    if (filtered.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Text(
                              'No alerts in this category',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final alert = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AlertCard(
                            alert: alert,
                            onTap: () {
                              Helpers.push(
                                context,
                                AlertDetailsScreen(alert: alert),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
