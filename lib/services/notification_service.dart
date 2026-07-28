import 'package:flutter/foundation.dart';
import 'package:postgrest/postgrest.dart';
import '../models/notification_model.dart';
import '../services/mock_database_service.dart';
import '../services/supabase_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _useSupabase = false;

  Future<void> initialize() async {
    try {
      final session = SupabaseService.client.auth.currentSession;
      _useSupabase = session != null;
    } catch (e) {
      _useSupabase = false;
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    debugPrint("Notification");
    debugPrint("Title: $title");
    debugPrint("Body: $body");
  }

  Future<List<NotificationModel>> getNotifications({String? category}) async {
    if (_useSupabase) {
      try {
        final client = SupabaseService.client.from('notifications');
        dynamic queryResult;

        if (category != null && category != 'All') {
          queryResult = await client
              .select()
              .eq('category', category)
              .order('created_at', ascending: false);
        } else {
          queryResult = await client
              .select()
              .order('created_at', ascending: false);
        }

        List<dynamic> rows;
        if (queryResult is List) {
          rows = queryResult;
        } else if (queryResult?.data is List) {
          rows = queryResult.data as List<dynamic>;
        } else {
          rows = const [];
        }

        return rows
            .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Supabase getNotifications error: $e');
      }
    }
    return MockDatabaseService.getNotificationsByCategory(category);
  }

  Future<int> getUnreadCount() async {
    if (_useSupabase) {
      try {
        final dynamic resp = await SupabaseService.client
            .from('notifications')
            .select()
            .eq('is_read', false)
            .count(CountOption.exact);

        if (resp is int) return resp;
        if (resp is PostgrestResponse) {
          final int? c = resp.count;
          if (c != null) return c;
          final d = resp.data;
          if (d is List) return d.length;
        }
        final dyn = resp as dynamic;
        if (dyn?.count is int) return dyn.count as int;
        if (dyn?.data is List) return (dyn.data as List).length;
        if (resp is List) return resp.length;
      } catch (e) {
        debugPrint('Supabase getUnreadCount error: $e');
      }
    }
    return MockDatabaseService.unreadNotificationCount;
  }

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

  Future<void> markAllAsRead() async {
    if (_useSupabase) {
      try {
        final userId = SupabaseService.client.auth.currentUser?.id;
        dynamic query = SupabaseService.client
            .from('notifications')
            .update({'is_read': true}).eq('is_read', false);
        if (userId != null) {
          query = query.eq('user_id', userId);
        }
        await query;
        return;
      } catch (e) {
        debugPrint('Supabase markAllAsRead error: $e');
      }
    }
    MockDatabaseService.markAllNotificationsAsRead();
  }

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

  Future<void> addNotification(NotificationModel notification) async {
    if (_useSupabase) {
      try {
        final userId = SupabaseService.client.auth.currentUser?.id;
        final map = notification.toMap();
        if (userId != null) {
          map['user_id'] = userId;
        }
        await SupabaseService.client.from('notifications').insert(map);
        return;
      } catch (e) {
        debugPrint('Supabase addNotification error: $e');
      }
    }
    MockDatabaseService.addNotification(notification);
  }
}
