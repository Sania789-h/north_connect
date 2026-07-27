import '../models/alert_model.dart';

class MockDatabaseService {
  static final List<AlertModel> _alerts = [
    AlertModel(
      id: "a1",
      title: "Landslide Warning",
      description: "A major landslide risk has been identified. Steep slopes are saturated due to continuous rainfall. Avoid travel near mountainous edges and follow official diversion routes.",
      category: "Safety",
      location: "Hunza, Gilgit-Baltistan",
      severity: "Critical",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AlertModel(
      id: "a2",
      title: "Flood Advisory",
      description: "River water levels are rising rapidly due to glacial melt and heavy upstream rainfall. Low-lying areas near river banks are at risk of flash flooding. Move to higher ground if advised.",
      category: "Weather",
      location: "Ghizer, Gilgit-Baltistan",
      severity: "High",
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AlertModel(
      id: "a3",
      title: "Road Closed",
      description: "Babusar Top section of Naran Road is temporarily closed due to snow accumulation and icy conditions. Maintenance crews are working to clear the route. Expected reopening in 6-8 hours.",
      category: "Road",
      location: "Babusar Top, Naran Road",
      severity: "High",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AlertModel(
      id: "a4",
      title: "Heavy Rain Alert",
      description: "Intense rainfall expected over the next 12-24 hours. Risk of urban flooding, reduced visibility, and slippery roads. Postpone non-essential travel and secure outdoor belongings.",
      category: "Weather",
      location: "Skardu, Gilgit-Baltistan",
      severity: "Medium",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AlertModel(
      id: "a5",
      title: "Snowfall Warning",
      description: "Heavy to moderate snowfall forecast for high-altitude regions. Road surfaces will become icy and dangerous. Ensure vehicles are equipped with tire chains and carry emergency supplies.",
      category: "Weather",
      location: "Astore, Gilgit-Baltistan",
      severity: "Medium",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AlertModel(
      id: "a6",
      title: "High Wind Alert",
      description: "Strong wind gusts up to 80 km/h expected. Risk of falling trees, damaged structures, and power outages. Secure loose outdoor items and exercise caution while driving high-profile vehicles.",
      category: "Safety",
      location: "Ghanche, Gilgit-Baltistan",
      severity: "Medium",
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
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

  // Add Methods
  static void addAlert(AlertModel alert) {
    _alerts.insert(0, alert);
  }

  static bool deleteAlert(String? id) {
    if (id == null || id.isEmpty) return false;
    final initialLength = _alerts.length;
    _alerts.removeWhere((a) => a.id == id);
    return _alerts.length < initialLength;
  }

  static void updateOfflineProfile(Map<String, dynamic> profile) {
    _offlineProfile = profile;
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
}
