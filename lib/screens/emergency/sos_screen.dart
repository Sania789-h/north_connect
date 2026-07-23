import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/colors.dart';
import '../../services/mock_database_service.dart';
import 'add_sos_screen.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  Future<List<Map<String, dynamic>>> getAlerts() async {
    try {
      final data = await Supabase.instance.client
          .from('sos_alerts')
          .select()
          .order('created_at', ascending: false);

      final dbAlerts = List<Map<String, dynamic>>.from(data);
      
      final localAlerts = MockDatabaseService.sosAlerts;
      final Set<String> existingIds = dbAlerts.map((a) => a['id']?.toString() ?? '').toSet();
      
      final combined = <Map<String, dynamic>>[];
      combined.addAll(localAlerts.where((a) => !existingIds.contains(a['id']?.toString())));
      combined.addAll(dbAlerts);
      
      combined.sort((a, b) {
        final dateA = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
        final dateB = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
        return dateB.compareTo(dateA);
      });
      
      return combined;
    } catch (e) {
      debugPrint("Supabase SOS query failed, using offline fallback: $e");
      return MockDatabaseService.sosAlerts;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "resolved":
        return AppColors.success;
      case "in progress":
      case "active":
        return Colors.orange;
      default:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Emergency SOS"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddSOSScreen(),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getAlerts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            final alerts = snapshot.data ?? [];

            if (alerts.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      "No SOS Alerts Found",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final status = alert['status'] ?? 'Pending';
                final statusColor = getStatusColor(status);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.error.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.emergency,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      alert['emergency_type'] ?? 'Emergency',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                alert['message'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    alert['location'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}