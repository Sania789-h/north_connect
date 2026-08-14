import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alert_model.dart';
import '../models/notification_model.dart';

class MockDatabaseService {
  static final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'n1',
      title: 'Emergency Alert: Landslide Warning',
      description:
          'A minor landslide has been reported near Attabad Lake, Hunza. Travelers are advised to avoid the Karakoram Highway section between Aliabad and Gulmit until further notice. Local rescue teams are on-site.',
      category: 'Emergency Alert',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'n2',
      title: 'Heavy Snowfall Expected in Skardu',
      description:
          'Meteorological department has issued an alert for moderate to heavy snowfall in Skardu and surrounding high-altitude regions over the next 24 hours. Temperature may drop to -8°C.',
      category: 'Weather',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      id: 'n3',
      title: 'Road Construction: Babusar Top',
      description:
          'Maintenance work is in progress on N-15 at Babusar Top. Expect delays of 2-3 hours. Work scheduled from 8 AM to 5 PM daily until completion. Alternative route via Kaghan Valley is open.',
      category: 'Road Alert',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    NotificationModel(
      id: 'n4',
      title: 'SCOM Network Restored in Deosai',
      description:
          'SCOM mobile network services have been fully restored in Deosai Plains and surrounding areas after a 12-hour outage caused by a damaged fiber optic cable.',
      category: 'Network',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: 'n5',
      title: 'SOS Alert Acknowledged',
      description:
          'Your SOS alert from Nagar Valley has been received by local emergency response team. Rescue vehicle dispatched with medical supplies. Estimated arrival: 45 minutes.',
      category: 'SOS',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    NotificationModel(
      id: 'n6',
      title: 'Rainfall Advisory: Gilgit Region',
      description:
          'Light to moderate rainfall expected in Gilgit city and adjoining areas this evening. Drivers are advised to exercise caution due to slippery roads and reduced visibility.',
      category: 'Weather',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NotificationModel(
      id: 'n7',
      title: 'Road Clearance Complete: KKH',
      description:
          'The Karakoram Highway section near Gilgit city that was blocked due to a rockslide has been cleared. Normal traffic flow has resumed.',
      category: 'Road Alert',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    NotificationModel(
      id: 'n8',
      title: 'Jazz Network Maintenance Tonight',
      description:
          'Scheduled network maintenance for Jazz subscribers in the Skardu region tonight from 2 AM to 4 AM. Brief service interruptions may occur during this window.',
      category: 'Network',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  static final List<AlertModel> _alerts = [
    AlertModel(
      id: "a1",
      title: "Landslide Warning",
      description: "Landslide risk is high in the above mentioned areas due to continuous rainfall. Avoid unnecessary travel and stay safe.",
      category: "Safety",
      location: "Hunza, Gilgit-Baltistan",
      severity: "High",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      safetyTips: [
        "Avoid steep areas",
        "Stay away from mountain slopes",
        "Follow local authorities",
      ],
    ),
    AlertModel(
      id: "a2",
      title: "Flood Advisory",
      description: "Water levels are rising in local rivers due to glacial melt. Avoid low-lying areas and river banks.",
      category: "Weather",
      location: "Ghizer, Gilgit-Baltistan",
      severity: "High",
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      safetyTips: [
        "Move to higher ground",
        "Do not cross flowing water",
        "Keep emergency supplies ready",
      ],
    ),
    AlertModel(
      id: "a3",
      title: "Road Closed",
      description: "Road is temporarily closed due to maintenance work. Alternative routes are available via Kaghan Valley.",
      category: "Road",
      location: "Babusar Top, Naran Road",
      severity: "High",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      safetyTips: [
        "Use alternative route via Kaghan",
        "Check road updates before travel",
        "Carry extra food and water",
      ],
    ),
    AlertModel(
      id: "a4",
      title: "Heavy Rain Alert",
      description: "Moderate to heavy rainfall expected in the region over the next 24 hours. Drivers should exercise caution.",
      category: "Weather",
      location: "Skardu, Gilgit-Baltistan",
      severity: "Medium",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      safetyTips: [
        "Drive slowly, roads may be slippery",
        "Keep headlights on in low visibility",
        "Avoid areas prone to flooding",
      ],
    ),
    AlertModel(
      id: "a5",
      title: "Snowfall Warning",
      description: "Moderate to heavy snowfall expected in high altitude regions. Travelers should carry tire chains.",
      category: "Weather",
      location: "Astore, Gilgit-Baltistan",
      severity: "Medium",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      safetyTips: [
        "Install tire chains on 4x4 vehicles",
        "Keep warm clothes and blankets",
        "Check weather before heading out",
      ],
    ),
    AlertModel(
      id: "a6",
      title: "High Wind Alert",
      description: "Strong winds expected across the region. Secure loose objects and be cautious while driving high-sided vehicles.",
      category: "Safety",
      location: "Ghanche, Gilgit-Baltistan",
      severity: "Medium",
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      safetyTips: [
        "Secure all outdoor objects",
        "Drive carefully on exposed roads",
        "Stay away from tall trees and power lines",
      ],
    ),
  ];

  static final List<Map<String, dynamic>> _weatherReports = [
    {
      'id': 'w1',
      'location': 'Skardu',
      'weather_type': 'Snowfall',
      'temperature': '-2°C',
      'description': 'Light snow showers, visibility is low. Roads are slippery.',
      'created_at': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
    },
    {
      'id': 'w2',
      'location': 'Hunza',
      'weather_type': 'Sunny',
      'temperature': '12°C',
      'description': 'Clear blue skies with chilly winds. Great weather for travel.',
      'created_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
    },
    {
      'id': 'w3',
      'location': 'Gilgit',
      'weather_type': 'Cloudy',
      'temperature': '16°C',
      'description': 'Overcast clouds, temperature is dropping gradually.',
      'created_at': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> _networkReports = [
    {
      'id': 'n1',
      'area': 'Hunza Valley (Aliabad)',
      'status': 'Online',
      'network_name': 'SCOM',
      'signal_strength': 'Strong (4G)',
      'issue': 'Working smoothly without any interruptions.',
      'created_at': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
    },
    {
      'id': 'n2',
      'area': 'Deosai Plains',
      'status': 'Offline',
      'network_name': 'Telenor',
      'signal_strength': 'No Signal',
      'issue': 'Temporary blackout due to severe weather in the region.',
      'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': 'n3',
      'area': 'Skardu City',
      'status': 'Online',
      'network_name': 'Zong',
      'signal_strength': 'Moderate (3G)',
      'issue': 'Slight congestion during evening hours.',
      'created_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> _sosAlerts = [
    {
      'id': 's1',
      'emergency_type': 'Vehicle Breakdown',
      'status': 'Resolved',
      'message': 'Tyre burst on the highway, requested support for replacement tools.',
      'location': 'Nagar Valley',
      'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
    },
    {
      'id': 's2',
      'emergency_type': 'Medical Help Needed',
      'status': 'Active',
      'message': 'Severe breathing difficulty due to high altitude sickness near Skardu Pass.',
      'location': 'Skardu',
      'created_at': DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
    },
  ];

  static Map<String, dynamic>? _offlineProfile;

  // Getters
  static List<AlertModel> get alerts => List.from(_alerts);
  static List<Map<String, dynamic>> get weatherReports => List.from(_weatherReports);
  static List<Map<String, dynamic>> get networkReports => List.from(_networkReports);
  static List<Map<String, dynamic>> get sosAlerts => List.from(_sosAlerts);
  static Map<String, dynamic>? get offlineProfile => _offlineProfile;
  static List<NotificationModel> get notifications => List.from(_notifications);

  static int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  // Add Methods
  static void addAlert(AlertModel alert) {
    _alerts.insert(0, alert);
  }

  static void updateOfflineProfile(Map<String, dynamic> profile) {
    _offlineProfile = profile;
    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('offline_profile', jsonEncode(profile));
      });
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> loadOfflineProfile() async {
    if (_offlineProfile != null) return _offlineProfile;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString('offline_profile');
      if (savedStr != null && savedStr.isNotEmpty) {
        _offlineProfile = Map<String, dynamic>.from(jsonDecode(savedStr));
        return _offlineProfile;
      }
    } catch (_) {}
    return null;
  }

  static void addWeather(Map<String, dynamic> weather) {
    _weatherReports.insert(0, {
      ...weather,
      'id': 'w_local_${DateTime.now().millisecondsSinceEpoch}',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static void addNetwork(Map<String, dynamic> network) {
    _networkReports.insert(0, {
      ...network,
      'id': 'n_local_${DateTime.now().millisecondsSinceEpoch}',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static void addSOS(Map<String, dynamic> sos) {
    _sosAlerts.insert(0, {
      ...sos,
      'id': 's_local_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'Active',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Notification Methods
  static void addNotification(NotificationModel notification) {
    final newNotif = notification.copyWith(
      id: notification.id ?? 'notif_local_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: notification.createdAt ?? DateTime.now(),
    );
    _notifications.insert(0, newNotif);
  }

  static void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  static void markAllNotificationsAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  static void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
  }

  static List<NotificationModel> getNotificationsByCategory(String? category) {
    if (category == null || category == 'All') {
      return List.from(_notifications);
    }
    return _notifications.where((n) => n.category == category).toList();
  }
}
