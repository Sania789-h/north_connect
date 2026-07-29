class SOSRequest {
  final String? id;
  final String? userId;
  final String emergencyType;
  final String? description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? contactNumber;
  final String status;
  final DateTime? createdAt;

  SOSRequest({
    this.id,
    this.userId,
    required this.emergencyType,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.contactNumber,
    this.status = 'Pending',
    this.createdAt,
  });

  factory SOSRequest.fromMap(Map<String, dynamic> map) {
    return SOSRequest(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString(),
      emergencyType: map['emergency_type']?.toString() ?? 'Emergency SOS',
      description: map['description']?.toString(),
      location: map['location']?.toString(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      contactNumber: map['contact_number']?.toString(),
      status: map['status']?.toString() ?? 'Pending',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'emergency_type': emergencyType,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (contactNumber != null) 'contact_number': contactNumber,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  SOSRequest copyWith({
    String? id,
    String? userId,
    String? emergencyType,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? contactNumber,
    String? status,
    DateTime? createdAt,
  }) {
    return SOSRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emergencyType: emergencyType ?? this.emergencyType,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactNumber: contactNumber ?? this.contactNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
