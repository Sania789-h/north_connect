import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          return _buildNotificationCard(notif);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notif['isNew'] ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notif['isNew']
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (notif['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(notif['icon'] as IconData, color: notif['color'] as Color, size: 22),
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
                        notif['title'],
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (notif['isNew'])
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif['body'],
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notif['time'],
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> _notifications = [
  {
    'title': 'Weather Alert',
    'body': 'Heavy rainfall expected in Hunza Valley. Plan your trip accordingly.',
    'time': '2 hours ago',
    'icon': Icons.cloud_outlined,
    'color': Colors.blue,
    'isNew': true,
  },
  {
    'title': 'Network Update',
    'body': 'Mobile network restored in Skardu region after maintenance.',
    'time': '5 hours ago',
    'icon': Icons.wifi_rounded,
    'color': Colors.purple,
    'isNew': true,
  },
  {
    'title': 'Safety Tip',
    'body': 'Always carry warm clothing when traveling to high-altitude areas.',
    'time': '1 day ago',
    'icon': Icons.shield_outlined,
    'color': AppColors.primary,
    'isNew': false,
  },
  {
    'title': 'New Destination',
    'body': 'Rama Meadows has been added to our featured destinations list.',
    'time': '2 days ago',
    'icon': Icons.explore_outlined,
    'color': AppColors.secondary,
    'isNew': false,
  },
  {
    'title': 'Community Alert',
    'body': 'Road construction on Karakoram Highway near Chillas. Expect delays.',
    'time': '3 days ago',
    'icon': Icons.warning_amber_rounded,
    'color': AppColors.warning,
    'isNew': false,
  },
];
