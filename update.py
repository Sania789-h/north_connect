import re

with open('lib/screens/home/home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the start of _buildSectionTitle
match = re.search(r'\s*// ─────────────────────────────────────────────\s*// Section Title', content)

if match:
    # Truncate content before this match
    content = content[:match.start()]

    # Append new methods
    new_methods = '''
  // ─────────────────────────────────────────────
  // Section Header
  // ─────────────────────────────────────────────
  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              children: [
                Text(
                  \\'View All\\',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F766E),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF0F766E), size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Quick Access
  // ─────────────────────────────────────────────
  Widget _buildQuickAccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(\\'Quick Access\\'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickAccessItem(Icons.cloud_rounded, \\'Weather\\', const Color(0xFF3B82F6)),
              _buildQuickAccessItem(Icons.warning_rounded, \\'Alerts\\', const Color(0xFFEF4444), badge: \\'3\\'),
              _buildQuickAccessItem(Icons.cell_tower_rounded, \\'Network\\', const Color(0xFF22C55E)),
              _buildQuickAccessItem(Icons.sos_rounded, \\'SOS\\', const Color(0xFFEF4444)),
              _buildQuickAccessItem(Icons.person_rounded, \\'Profile\\', const Color(0xFF8B5CF6)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(IconData icon, String label, Color color, {String? badge}) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            if (badge != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Latest Alerts
  // ─────────────────────────────────────────────
  Widget _buildLatestAlerts() {
    return Column(
      children: [
        _buildSectionHeader(\\'Latest Alerts\\'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                _buildAlertItem(
                  icon: Icons.landslide_rounded,
                  iconColor: const Color(0xFFEF4444),
                  title: \\'Landslide Warning\\',
                  location: \\'Hunza, Gilgit-Baltistan\\',
                  timeAgo: \\'2h ago\\',
                ),
                Divider(height: 1, color: Colors.grey.shade200, indent: 64),
                _buildAlertItem(
                  icon: Icons.flood_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: \\'Flood Advisory\\',
                  location: \\'Ghizer, Gilgit-Baltistan\\',
                  timeAgo: \\'5h ago\\',
                ),
                Divider(height: 1, color: Colors.grey.shade200, indent: 64),
                _buildAlertItem(
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: \\'Road Closed\\',
                  location: \\'Babusar Top, Naran Road\\',
                  timeAgo: \\'1d ago\\',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String location,
    required String timeAgo,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  location,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                timeAgo,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 16),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Network Status
  // ─────────────────────────────────────────────
  Widget _buildNetworkStatus() {
    return Column(
      children: [
        _buildSectionHeader(\\'Network Status\\'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNetworkItem(\\'SCOM\\', Icons.language, const Color(0xFF22C55E), 4, const Color(0xFF2563EB)),
                _buildNetworkItem(\\'Jazz\\', Icons.language, const Color(0xFF22C55E), 4, const Color(0xFFDC2626)),
                _buildNetworkItem(\\'Zong 4G\\', Icons.language, const Color(0xFF22C55E), 4, const Color(0xFF16A34A)),
                _buildNetworkItem(\\'Telenor\\', Icons.language, const Color(0xFFF59E0B), 2, const Color(0xFF2563EB)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkItem(String name, IconData logoIcon, Color statusColor, int bars, Color logoColor) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade50,
          ),
          child: Icon(logoIcon, color: logoColor, size: 24),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3.5,
              height: 6.0 + (index * 2.5),
              decoration: BoxDecoration(
                color: index < bars ? statusColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          bars == 4 ? \\'Good\\' : \\'Fair\\',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Emergency SOS
  // ─────────────────────────────────────────────
  Widget _buildEmergencySOS() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call_rounded, color: Color(0xFFEF4444), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    \\'Emergency SOS\\',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    \\'Tap to send your location to emergency contacts\\',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    \\'Send SOS\\',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFEF4444), size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
'''
    
    with open('lib/screens/home/home_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content + new_methods)
    print('Updated home_screen.dart successfully.')
else:
    print('Could not find match.')

