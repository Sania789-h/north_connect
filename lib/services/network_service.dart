import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/network_model.dart';
import 'mock_database_service.dart';
import 'supabase_service.dart';

class NetworkService {
  static final SupabaseClient _supabase = SupabaseService.client;

  /// Fetches network reports from Supabase DB with offline fallback.
  static Future<List<NetworkModel>> getNetworkReports() async {
    try {
      final List<dynamic> data = await _supabase
          .from('network_reports')
          .select()
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 8));

      final dbReports = data
          .map((row) => NetworkModel.fromMap(Map<String, dynamic>.from(row as Map)))
          .toList();

      final localReports = MockDatabaseService.networkReports
          .map((map) => NetworkModel.fromMap(map))
          .toList();

      final Set<String> dbIds = dbReports.map((r) => r.id ?? '').toSet();
      final combined = <NetworkModel>[];
      combined.addAll(dbReports);
      combined.addAll(localReports.where((r) => r.id != null && !dbIds.contains(r.id)));

      combined.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.now();
        final dateB = b.createdAt ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      return combined;
    } catch (e) {
      debugPrint("NetworkService getNetworkReports failed ($e), using local fallback.");
      return MockDatabaseService.networkReports
          .map((map) => NetworkModel.fromMap(map))
          .toList();
    }
  }

  /// Submits a network report to Supabase DB.
  static Future<NetworkModel> submitNetworkReport({
    required String location,
    required String networkType,
    required String networkStatus,
    required String signalStrength,
    required String description,
  }) async {
    final user = _supabase.auth.currentUser;
    final model = NetworkModel(
      userId: user?.id,
      location: location,
      networkType: networkType,
      signalStrength: signalStrength,
      networkStatus: networkStatus,
      description: description,
      createdAt: DateTime.now(),
    );

    try {
      final payload = model.toMap();
      final List<dynamic> res = await _supabase
          .from('network_reports')
          .insert(payload)
          .select()
          .timeout(const Duration(seconds: 8));

      if (res.isNotEmpty) {
        final created = NetworkModel.fromMap(Map<String, dynamic>.from(res.first as Map));
        MockDatabaseService.addNetwork(created.toMap());
        return created;
      }
    } catch (e) {
      debugPrint("NetworkService submitNetworkReport failed ($e), saving to local database.");
    }

    MockDatabaseService.addNetwork(model.toMap());
    return model;
  }
}
