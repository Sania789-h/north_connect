import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/helpers.dart';
import '../../models/alert_model.dart';

class AlertDetailsScreen extends StatelessWidget {
  final AlertModel alert;

  const AlertDetailsScreen({
    super.key,
    required this.alert,
  });

  Color getHeaderColor(String category, String title) {
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

  Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case "critical":
      case "high":
        return const Color(0xFFEF4444);
      case "medium":
        return const Color(0xFFFB923C);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = getHeaderColor(alert.category, alert.title);
    final icon = getCategoryIcon(alert.category, alert.title);
    final severityColor = getSeverityColor(alert.severity);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Helpers.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      alert.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      alert.timeAgo,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    Icons.location_on_rounded,
                    const Color(0xFF1E293B),
                    'Location',
                    alert.location,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.warning_amber_rounded,
                    const Color(0xFFFB923C),
                    'Severity',
                    alert.severity,
                    valueColor: severityColor,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Description',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    alert.description,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF334155),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (alert.safetyTips.isNotEmpty) ...[
                    Text(
                      'Safety Tips',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...alert.safetyTips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: const Color(0xFF067A46),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF334155),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 26),
                  ],
                  Text(
                    'Share Alert',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildShareIcon(
                        const Color(0xFF25D366),
                        Icons.chat_bubble_outline_rounded,
                      ),
                      const SizedBox(width: 24),
                      _buildShareIcon(
                        const Color(0xFF1877F2),
                        Icons.facebook_rounded,
                      ),
                      const SizedBox(width: 24),
                      _buildShareIcon(
                        const Color(0xFFFB923C),
                        Icons.alternate_email_rounded,
                      ),
                      const SizedBox(width: 24),
                      _buildShareIcon(
                        const Color(0xFF067A46),
                        Icons.share_location_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Helpers.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF067A46),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'I Understand',
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    Color iconColor,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareIcon(Color color, IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}
