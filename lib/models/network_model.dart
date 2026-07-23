class NetworkModel {
  final String area;
  final String signalStrength; // weak, medium, strong
  final bool hasInternet;
  final String updatedAt;

  NetworkModel({
    required this.area,
    required this.signalStrength,
    required this.hasInternet,
    required this.updatedAt,
  });

  factory NetworkModel.fromMap(Map<String, dynamic> map) {
    return NetworkModel(
      area: map['area'] ?? '',
      signalStrength: map['signalStrength'] ?? '',
      hasInternet: map['hasInternet'] ?? false,
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'area': area,
      'signalStrength': signalStrength,
      'hasInternet': hasInternet,
      'updatedAt': updatedAt,
    };
  }
}