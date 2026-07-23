class AlertModel {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String severity;
  final DateTime? createdAt;

  AlertModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.severity,
    this.createdAt,
  });

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      severity: map['severity'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
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
    };
  }
}