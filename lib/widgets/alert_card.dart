import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  Color getCategoryBgColor(String category, String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('landslide')) return const Color(0xFFEF4444);
    if (titleLower.contains('flood')) return const Color(0xFF3B82F6);
    if (titleLower.contains('road closed') || titleLower.contains('road')) return const Color(0xFFFB923C);
    if (titleLower.contains('heavy rain') || titleLower.contains('rain')) return const Color(0xFF2563EB);
    if (titleLower.contains('snowfall') || titleLower.contains('snow')) return const Color(0xFF14B8A6);
    if (titleLower.contains('wind')) return const Color(0xFF0D9488);

    switch (category.toLowerCase()) {
      case "weather":
        return const Color(0xFF3B82F6);
      case "road":
        return const Color(0xFFFB923C);
      case "safety":
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData getCategoryIcon(String category, String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('landslide')) return Icons.terrain_rounded;
    if (titleLower.contains('flood')) return Icons.waves_rounded;
    if (titleLower.contains('road closed')) return Icons.traffic_rounded;
    if (titleLower.contains('heavy rain') || titleLower.contains('rain')) return Icons.water_drop_rounded;
    if (titleLower.contains('snowfall') || titleLower.contains('snow')) return Icons.ac_unit_rounded;
    if (titleLower.contains('wind')) return Icons.air_rounded;

    switch (category.toLowerCase()) {
      case "weather":
        return Icons.cloud_rounded;
      case "road":
        return Icons.traffic_rounded;
      case "safety":
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = getCategoryBgColor(alert.category, alert.title);
    final icon = getCategoryIcon(alert.category, alert.title);
    final isNew = alert.isNew;

    // Dark-aware colors
    final cardBg = isDark
        ? (isNew ? const Color(0xFF0D2318) : const Color(0xFF1E293B))
        : (isNew ? const Color(0xFFF0FDF4) : Colors.white);
    final cardBorder = isNew
        ? const Color(0xFF067A46).withValues(alpha: 0.25)
        : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.transparent);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.04);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: cardBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    if (isNew)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF067A46),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'NEW',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: isNew ? FontWeight.w800 : FontWeight.w700,
                                color: textPrimary,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        alert.location,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      alert.timeAgo,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isNew ? const Color(0xFF067A46) : const Color(0xFF94A3B8),
                        fontWeight: isNew ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (isNew)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF067A46),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
