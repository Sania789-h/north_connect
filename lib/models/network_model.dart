class NetworkModel {
  final String? id;
  final String? userId;
  final String location;
  final String networkType;
  final String signalStrength;
  final String networkStatus;
  final String description;
  final DateTime? createdAt;

  NetworkModel({
    this.id,
    this.userId,
    required this.location,
    required this.networkType,
    required this.signalStrength,
    required this.networkStatus,
    required this.description,
    this.createdAt,
  });

  String get timeAgo {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);

    if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  factory NetworkModel.fromMap(Map<String, dynamic> map) {
    final rawCreatedAt = map['created_at'] ?? map['updatedAt'];
    return NetworkModel(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString() ?? map['userId']?.toString(),
      location: map['location']?.toString() ?? map['area']?.toString() ?? '',
      networkType: map['network_type']?.toString() ?? map['network_name']?.toString() ?? '',
      signalStrength: map['signal_strength']?.toString() ?? map['signalStrength']?.toString() ?? 'Strong (4G)',
      networkStatus: map['network_status']?.toString() ?? map['status']?.toString() ?? 'Good',
      description: map['description']?.toString() ?? map['issue']?.toString() ?? '',
      createdAt: rawCreatedAt != null ? DateTime.tryParse(rawCreatedAt.toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'location': location,
      'area': location,
      'network_type': networkType,
      'network_name': networkType,
      'signal_strength': signalStrength,
      'signalStrength': signalStrength,
      'network_status': networkStatus,
      'status': networkStatus,
      'description': description,
      'issue': description,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}