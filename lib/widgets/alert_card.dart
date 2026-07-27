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

  ({Color color, IconData icon}) getAlertVisuals(String category, String title) {
    final lowerTitle = title.toLowerCase();
    final lowerCategory = category.toLowerCase();

    if (lowerTitle.contains("landslide")) {
      return (
        color: const Color(0xFFEF4444),
        icon: Icons.landslide_sharp,
      );
    } else if (lowerTitle.contains("flood")) {
      return (
        color: const Color(0xFF2563EB),
        icon: Icons.water_sharp,
      );
    } else if (lowerTitle.contains("road") || lowerCategory == "road") {
      return (
        color: const Color(0xFFF97316),
        icon: Icons.traffic_sharp,
      );
    } else if (lowerTitle.contains("rain")) {
      return (
        color: const Color(0xFF2563EB),
        icon: Icons.water_drop_sharp,
      );
    } else if (lowerTitle.contains("snowfall") || lowerTitle.contains("snow")) {
      return (
        color: const Color(0xFF06B6D4),
        icon: Icons.ac_unit_sharp,
      );
    } else if (lowerTitle.contains("wind")) {
      return (
        color: const Color(0xFF14B8A6),
        icon: Icons.air_sharp,
      );
    } else if (lowerCategory == "weather") {
      return (
        color: const Color(0xFF2563EB),
        icon: Icons.cloud_sharp,
      );
    } else if (lowerCategory == "safety") {
      return (
        color: const Color(0xFFEF4444),
        icon: Icons.shield_sharp,
      );
    } else {
      return (
        color: AppColors.primary,
        icon: Icons.notifications_sharp,
      );
    }
  }

  String formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return "";
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays >= 1) {
      final days = diff.inDays;
      return "${days}d ago";
    } else if (diff.inHours >= 1) {
      final hours = diff.inHours;
      return "${hours}h ago";
    } else if (diff.inMinutes >= 1) {
      final mins = diff.inMinutes;
      return "${mins}m ago";
    } else {
      return "Just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    final visuals = getAlertVisuals(alert.category, alert.title);
    final timeAgo = formatTimeAgo(alert.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: visuals.color.withValues(alpha: 0.08),
          highlightColor: visuals.color.withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: visuals.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    visuals.icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          alert.location,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                            height: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
