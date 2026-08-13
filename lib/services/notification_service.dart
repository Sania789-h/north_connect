import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../services/mock_database_service.dart';
import '../services/supabase_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Always try Supabase first — no need to check session manually;
  // Supabase SDK handles auth state internally.
  bool get _useSupabase {
    try {
      return SupabaseService.client.auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Call this once before using; kept for backwards-compat but now a no-op.
  Future<void> initialize() async {}

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    debugPrint('Notification — Title: $title | Body: $body');
  }

  // ── GET NOTIFICATIONS ─────────────────────────────────────────
  Future<List<NotificationModel>> getNotifications({String? category}) async {
    if (_useSupabase) {
      try {
        final userId = SupabaseService.client.auth.currentUser!.id;
        var query = SupabaseService.client
            .from('notifications')
            .select()
            .eq('user_id', userId);

        if (category != null && category != 'All') {
          query = query.eq('category', category);
        }

        final List<dynamic> rows =
            await query.order('created_at', ascending: false);

        return rows
            .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Supabase getNotifications error: $e');
      }
    }
    return MockDatabaseService.getNotificationsByCategory(category);
  }

  // ── UNREAD COUNT ──────────────────────────────────────────────
  Future<int> getUnreadCount() async {
    if (_useSupabase) {
      try {
        final userId = SupabaseService.client.auth.currentUser!.id;
        final List<dynamic> rows = await SupabaseService.client
            .from('notifications')
            .select()
            .eq('user_id', userId)
            .eq('is_read', false);
        return rows.length;
      } catch (e) {
        debugPrint('Supabase getUnreadCount error: $e');
      }
    }
    return MockDatabaseService.unreadNotificationCount;
  }

  // ── MARK AS READ ──────────────────────────────────────────────
  Future<void> markAsRead(String id) async {
    if (_useSupabase) {
      try {
        await SupabaseService.client
            .from('notifications')
            .update({'is_read': true}).eq('id', id);
        return;
      } catch (e) {
        debugPrint('Supabase markAsRead error: $e');
      }
    }
    MockDatabaseService.markNotificationAsRead(id);
  }

  // ── MARK ALL READ ─────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    if (_useSupabase) {
      try {
        final userId = SupabaseService.client.auth.currentUser?.id;
        if (userId != null) {
          await SupabaseService.client
              .from('notifications')
              .update({'is_read': true})
              .eq('user_id', userId)
              .eq('is_read', false);
        }
        return;
      } catch (e) {
        debugPrint('Supabase markAllAsRead error: $e');
      }
    }
    MockDatabaseService.markAllNotificationsAsRead();
  }

  // ── DELETE ────────────────────────────────────────────────────
  Future<void> deleteNotification(String id) async {
    if (_useSupabase) {
      try {
        await SupabaseService.client
            .from('notifications')
            .delete()
            .eq('id', id);
        return;
      } catch (e) {
        debugPrint('Supabase deleteNotification error: $e');
      }
    }
    MockDatabaseService.deleteNotification(id);
  }

  // ── ADD NOTIFICATION ──────────────────────────────────────────
  Future<void> addNotification(NotificationModel notification) async {
    if (_useSupabase) {
      try {
        final userId = SupabaseService.client.auth.currentUser?.id;
        final map = notification.toMap()..remove('id');
        if (userId != null) map['user_id'] = userId;
        await SupabaseService.client.from('notifications').insert(map);
        return;
      } catch (e) {
        debugPrint('Supabase addNotification error: $e');
      }
    }
    MockDatabaseService.addNotification(notification);
  }
}
