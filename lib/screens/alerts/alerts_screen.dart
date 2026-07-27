import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/colors.dart';
import '../../models/alert_model.dart';
import '../../widgets/alert_card.dart';
import '../../services/mock_database_service.dart';
import 'add_alert_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _selectedFilter = "All";
  final List<String> _filters = const ["All", "Weather", "Road", "Safety"];

  Future<List<AlertModel>> getAlerts() async {
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

  List<AlertModel> applyFilter(List<AlertModel> alerts) {
    if (_selectedFilter == "All") return alerts;
    return alerts.where((a) => a.category.toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case "safety":
        return const Color(0xFFEF4444);
      case "weather":
        return const Color(0xFF2563EB);
      case "road":
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF14B8A6);
    }
  }

  Future<void> deleteAlert(AlertModel alert) async {
    Navigator.pop(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 26),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Delete Alert?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to permanently delete \"${alert.title}\"? This action cannot be undone.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text("Cancel"),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text("Delete"),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );

    if (confirmed != true) return;

    bool deleted = false;
    String? errorMsg;

    try {
      if (alert.id != null && !alert.id!.startsWith("local_")) {
        await Supabase.instance.client
            .from('alerts')
            .delete()
            .eq('id', alert.id!);
      }
      MockDatabaseService.deleteAlert(alert.id);
      deleted = true;
    } catch (e) {
      errorMsg = e.toString();
      deleted = MockDatabaseService.deleteAlert(alert.id);
    }

    if (mounted) {
      if (deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  "\"${alert.title}\" deleted successfully",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  "Failed to delete alert${errorMsg != null ? ': $errorMsg' : ''}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      setState(() {});
    }
  }

  void showAlertDetail(AlertModel alert) {
    final categoryColor = getCategoryColor(alert.category);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.68,
        minChildSize: 0.45,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: categoryColor.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      alert.category.toLowerCase() == "safety"
                          ? Icons.shield_sharp
                          : alert.category.toLowerCase() == "road"
                              ? Icons.traffic_sharp
                              : Icons.cloud_sharp,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            alert.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: categoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),
              _buildDetailRow(
                icon: Icons.location_on_outlined,
                label: "Location",
                value: alert.location,
                iconColor: categoryColor,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                icon: Icons.circle_notifications,
                label: "Severity",
                value: alert.severity,
                iconColor: _getSeverityColor(alert.severity),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                icon: Icons.access_time_outlined,
                label: "Reported",
                value: _formatFullTime(alert.createdAt),
                iconColor: Colors.grey.shade600,
              ),
              const SizedBox(height: 24),
              const Text(
                "Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                alert.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () async => deleteAlert(alert),
                        icon: const Icon(Icons.delete_outline_rounded, size: 19),
                        label: const Text("Delete"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error, width: 1.3),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text("Close"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: categoryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case "critical":
        return AppColors.error;
      case "high":
        return AppColors.warning;
      case "medium":
        return AppColors.primary;
      default:
        return AppColors.success;
    }
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatFullTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays >= 1) {
      return "${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago";
    } else if (diff.inHours >= 1) {
      return "${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago";
    } else if (diff.inMinutes >= 1) {
      return "${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago";
    } else {
      return "Just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Alerts",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.3,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                setState(() {});
              },
              child: FutureBuilder<List<AlertModel>>(
                future: getAlerts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 56,
                            color: AppColors.error.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Error: ${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 38,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No Alerts Available",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tap + to add your first alert",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredAlerts = applyFilter(snapshot.data!);

                  if (filteredAlerts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_alt_off_rounded,
                            size: 56,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No $_selectedFilter alerts yet",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: filteredAlerts.length,
                    itemBuilder: (context, index) {
                      final alert = filteredAlerts[index];
                      return AlertCard(
                        alert: alert,
                        onTap: () => showAlertDetail(alert),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
