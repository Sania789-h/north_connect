class AlertModel {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String severity;
  final DateTime? createdAt;
  final List<String> safetyTips;
  bool isRead;

  AlertModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.severity,
    this.createdAt,
    this.safetyTips = const [],
    this.isRead = false,
  });

  String get timeAgo {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);

    if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours>= 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool get isNew {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final diff = now.difference(createdAt!);
    return diff.inHours < 24 && !isRead;
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      severity: map['severity'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      safetyTips: map['safety_tips'] != null
          ? List<String>.from(map['safety_tips'])
          : [],
      isRead: map['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'severity': severity,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'safety_tips': safetyTips,
      'is_read': isRead,
    };
  }
}
