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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Alerts",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddAlertScreen(),
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
        child: FutureBuilder<List<AlertModel>>(
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

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No Alerts Available",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            final alerts = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return AlertCard(
                  alert: alert,
                  onTap: () {
                    // Option to show full alert info dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(alert.title),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Category: ${alert.category}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Location: ${alert.location}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Severity: ${alert.severity}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Text(alert.description),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}