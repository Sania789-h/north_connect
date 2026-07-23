import 'package:flutter/foundation.dart';

class NotificationService {

  Future<void> initialize() async {
    // Notification setup yahan hoga
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    debugPrint("Notification");
    debugPrint("Title: $title");
    debugPrint("Body: $body");
  }
}