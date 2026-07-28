import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../core/constants/colors.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case "critical":
        return AppColors.error;
      case "high":
        return AppColors.warning;
      case "medium":
        return AppColors.primary;
      default:
        return AppColors.success;
    }
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case "Road Alert":
        return Icons.traffic;
      case "Weather Alert":
        return Icons.cloud;
      case "Emergency Alert":
        return Icons.emergency;
      case "Network Alert":
        return Icons.wifi;
      case "Utility Alert":
        return Icons.power;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = getSeverityColor(alert.severity);
    final categoryIcon = getCategoryIcon(alert.category);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: severityColor.withValues(alpha: 0.12),
                child: Icon(categoryIcon, color: severityColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: severityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            alert.severity,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      alert.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          alert.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.label_outline, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          alert.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
