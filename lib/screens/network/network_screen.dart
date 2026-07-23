import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/colors.dart';
import '../../services/mock_database_service.dart';
import 'add_network_report_screen.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  Future<List<Map<String, dynamic>>> getReports() async {
    try {
      final data = await Supabase.instance.client
          .from('network_reports')
          .select()
          .order('created_at', ascending: false);

      final dbReports = List<Map<String, dynamic>>.from(data);
      
      final localReports = MockDatabaseService.networkReports;
      final Set<String> existingIds = dbReports.map((r) => r['id']?.toString() ?? '').toSet();
      
      final combined = <Map<String, dynamic>>[];
      combined.addAll(localReports.where((r) => !existingIds.contains(r['id']?.toString())));
      combined.addAll(dbReports);
      
      combined.sort((a, b) {
        final dateA = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
        final dateB = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
        return dateB.compareTo(dateA);
      });
      
      return combined;
    } catch (e) {
      debugPrint("Supabase network query failed, using offline fallback: $e");
      return MockDatabaseService.networkReports;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Network Reports"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddNetworkReportScreen(),
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
          future: getReports(),
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

            final reports = snapshot.data ?? [];

            if (reports.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      "No Reports Found",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final isOnline = report['status'] == "Online";
                final statusColor = isOnline ? AppColors.success : AppColors.error;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: statusColor.withValues(alpha: 0.1),
                          child: Icon(
                            isOnline ? Icons.wifi : Icons.wifi_off,
                            color: statusColor,
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
                                      report['area'] ?? '',
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
                                      report['status'] ?? 'Offline',
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
                                "Provider: ${report['network_name'] ?? ''}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Signal: ${report['signal_strength'] ?? ''}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (report['issue'] != null && (report['issue'] as String).isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  report['issue'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
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