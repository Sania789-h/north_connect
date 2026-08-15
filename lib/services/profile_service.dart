import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mock_database_service.dart';

class ProfileService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Ensures the 'avatars' storage bucket exists and is public on Supabase.
  static Future<void> _ensureAvatarsBucketExists() async {
    try {
      await _supabase.storage.getBucket('avatars');
    } catch (_) {
      try {
        await _supabase.storage.createBucket(
          'avatars',
          const BucketOptions(public: true),
        );
        debugPrint("ProfileService: Created public 'avatars' storage bucket.");
      } catch (createErr) {
        debugPrint("ProfileService: Storage bucket check note: $createErr");
      }
    }
  }

  /// Uploads an image file to Supabase Storage ('avatars' bucket) and returns the public URL.
  /// If bucket or upload fails, falls back to base64 Data URI or local path.
  static Future<String?> uploadAvatar(XFile file) async {
    final user = _supabase.auth.currentUser;
    final userId = user?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final Uint8List bytes = await file.readAsBytes();
      final String fileExt = file.name.contains('.')
          ? file.name.split('.').last.toLowerCase()
          : 'jpg';
      final String fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final String filePath = fileName;

      // 1. Ensure backend bucket exists
      await _ensureAvatarsBucketExists();

      debugPrint("ProfileService: Uploading avatar to Supabase Storage bucket 'avatars', path: $filePath");

      // 2. Upload binary data to Supabase Storage bucket
      await _supabase.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      // 3. Get Public URL with timestamp cache buster
      final String baseUrl =
          _supabase.storage.from('avatars').getPublicUrl(filePath);
      final String publicUrl = '$baseUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      debugPrint("ProfileService: Avatar upload successful. Public URL: $publicUrl");
      return publicUrl;
    } catch (e) {
      debugPrint("ProfileService: Storage upload failed ($e). Using local fallback.");
      try {
        // Fallback: If smaller image, create base64 Data URI so backend & offline DB can store it directly
        final Uint8List bytes = await file.readAsBytes();
        if (bytes.lengthInBytes < 500 * 1024) {
          final String fileExt = file.name.contains('.')
              ? file.name.split('.').last.toLowerCase()
              : 'jpeg';
          final String base64Str = base64Encode(bytes);
          return 'data:image/$fileExt;base64,$base64Str';
        }
      } catch (_) {}
      return file.path;
    }
  }

  /// Updates profile details in Supabase DB, Supabase Auth Metadata, and MockDatabaseService.
  static Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String email,
    required String avatarUrl,
    String? bio,
    String? location,
  }) async {
    final currentUser = _supabase.auth.currentUser;
    final String userId = currentUser?.id ?? 'local';

    final updatedProfile = <String, dynamic>{
      'id': userId,
      'full_name': fullName.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'avatar_url': avatarUrl.trim(),
      'bio': bio ?? '',
      'location': location ?? 'Gilgit-Baltistan',
    };

    // 1. Save to local persistent storage immediately
    MockDatabaseService.updateOfflineProfile(
        Map<String, dynamic>.from(updatedProfile));

    if (currentUser == null) return true;

    final dbPayload = <String, dynamic>{
      'id': currentUser.id,
      'full_name': fullName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'avatar_url': avatarUrl.trim(),
      'bio': bio ?? '',
      'location': location ?? 'Gilgit-Baltistan',
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      debugPrint("ProfileService: Upserting profile with avatar_url=$avatarUrl");
      await _supabase.from('profiles').upsert(dbPayload).timeout(const Duration(seconds: 10));
      debugPrint("ProfileService: Profile upsert successful.");
    } catch (e) {
      debugPrint("ProfileService: DB upsert error: $e");
    }

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName.trim(),
            'avatar_url': avatarUrl.trim(),
          },
          email: email.trim().isNotEmpty && email.trim().contains('@')
              ? email.trim()
              : null,
        ),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint("ProfileService: Auth metadata update error: $e");
    }

    return true;
  }
}
