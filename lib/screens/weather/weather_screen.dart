import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/colors.dart';
import '../../services/mock_database_service.dart';
import 'add_weather_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<List<Map<String, dynamic>>> getWeatherReports() async {
    try {
      final data = await Supabase.instance.client
          .from('weather_reports')
          .select()
          .order('created_at', ascending: false);

      final dbReports = List<Map<String, dynamic>>.from(data);
      
      final localReports = MockDatabaseService.weatherReports;
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
      debugPrint("Supabase weather query failed, using offline fallback: $e");
      return MockDatabaseService.weatherReports;
    }
  }

  IconData getWeatherIcon(String type) {
    switch (type) {
      case "Sunny":
        return Icons.wb_sunny;
      case "Cloudy":
        return Icons.cloud;
      case "Rainy":
        return Icons.water_drop;
      case "Snowfall":
        return Icons.ac_unit;
      case "Thunderstorm":
        return Icons.thunderstorm;
      default:
        return Icons.cloud;
    }
  }

  Color getWeatherColor(String type) {
    switch (type) {
      case "Sunny":
        return Colors.orange;
      case "Cloudy":
        return Colors.blueGrey;
      case "Rainy":
        return Colors.blue;
      case "Snowfall":
        return Colors.lightBlue;
      case "Thunderstorm":
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Weather Reports"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddWeatherScreen(),
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
          future: getWeatherReports(),
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
                      "No Weather Reports Found",
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
                final type = report['weather_type'] ?? 'Sunny';
                final weatherColor = getWeatherColor(type);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: weatherColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            getWeatherIcon(type),
                            size: 28,
                            color: weatherColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report['location'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$type • Temp: ${report['temperature'] ?? ''}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                report['description'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
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