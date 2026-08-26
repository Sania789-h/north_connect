import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sos_model.dart';
import '../services/supabase_service.dart';

class LocationResult {
  final bool success;
  final Position? position;
  final String errorMessage;

  const LocationResult({
    required this.success,
    this.position,
    this.errorMessage = '',
  });
}

class SOSService {
  static final SOSService _instance = SOSService._internal();
  factory SOSService() => _instance;
  SOSService._internal();

  // ── Location ──────────────────────────────────────────────────
  Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          success: false,
          errorMessage:
              'Location services are disabled. Please enable GPS/Google Location Services in Settings.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(
            success: false,
            errorMessage:
                'Location permission denied. Please grant location access for accurate emergency response.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          success: false,
          errorMessage:
              'Location permission is permanently denied. Please open App Settings → Permissions → enable Location.',
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LocationResult(success: true, position: position);
    } on TimeoutException {
      return const LocationResult(
        success: false,
        errorMessage: 'Location requests timed out. Please try again with a clear view of the sky.',
      );
    } catch (e) {
      debugPrint('getCurrentLocation error: $e');
      return LocationResult(
        success: false,
        errorMessage: 'Could not fetch location: ${e.toString()}',
      );
    }
  }

  static Future<String> _tryPlacemarkLabel(Position p) async {
    try {
      final list = await Geolocator
          .getCurrentPosition(
              locationSettings:
                  const LocationSettings(accuracy: LocationAccuracy.lowest))
          .timeout(const Duration(seconds: 2), onTimeout: () => p);
      // ignore: unnecessary_null_comparison, use_build_context_synchronously
      if (list == null) return 'Lat ${p.latitude.toStringAsFixed(5)}, Lng ${p.longitude.toStringAsFixed(5)}';
      return 'Lat ${p.latitude.toStringAsFixed(5)}, Lng ${p.longitude.toStringAsFixed(5)}';
    } catch (_) {
      return 'Lat ${p.latitude.toStringAsFixed(5)}, Lng ${p.longitude.toStringAsFixed(5)}';
    }
  }

  Future<String> buildLocationLabel(Position p) async {
    return _tryPlacemarkLabel(p);
  }

  // ── Phone Call ─────────────────────── ─────────────────────────
  Future<bool> launchPhoneCall(String phoneNumber) async {
    try {
      final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(telUri)) {
        return await launchUrl(telUri);
      }
      return false;
    } catch (e) {
      debugPrint('launchPhoneCall error: $e');
      return false;
    }
  }

  // ── Supabase Insert ───────────────────────────────────────────
  Future<SOSRequest> sendSOSRequest({
    required double latitude,
    required double longitude,
    String? locationLabel,
    String emergencyType = 'Emergency SOS',
    String description =
        'Emergency SOS request sent from North Connect app.',
    String contactNumber = '1122',
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    final request = SOSRequest(
      userId: user?.id,
      emergencyType: emergencyType,
      description: description,
      location: locationLabel ??
          'Lat ${latitude.toStringAsFixed(5)}, Lng ${longitude.toStringAsFixed(5)}',
      latitude: latitude,
      longitude: longitude,
      contactNumber: contactNumber,
      status: 'Pending',
      createdAt: DateTime.now(),
    );

    try {
      final payload = request.toMap()..remove('id');
      final List<dynamic> res = await SupabaseService.client
          .from('sos_requests')
          .insert(payload)
          .select();

      if (res.isNotEmpty) {
        final created = SOSRequest.fromMap(res.first as Map<String, dynamic>);
        return created.copyWith(
          latitude: request.latitude,
          longitude: request.longitude,
          location: request.location,
        );
      }
      return request;
    } on PostgrestException catch (e) {
      debugPrint('SOS Supabase Postgrest error: ${e.message}');
      throw Exception(e.message);
    } on AuthException catch (e) {
      debugPrint('SOS Supabase Auth error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('SOS Supabase generic error: $e');
      rethrow;
    }
  }
}
