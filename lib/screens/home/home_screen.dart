import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_images.dart';
import '../../services/mock_database_service.dart';
import '../../services/weather_service.dart';
import '../../widgets/avatar_widget.dart';
import '../sos/sos_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  final VoidCallback? onExploreTap;

  const HomeScreen({
    super.key,
    this.onNavigateTab,
    this.onExploreTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _loading = true;
  String _error = '';
  WeatherData? _data;
  String _userAvatarUrl = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    // Start animations immediately so screen is never blank
    _fadeCtrl.value = 1.0;
    _slideCtrl.value = 1.0;

    _loadWeather();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final offline = await MockDatabaseService.loadOfflineProfile();
      final user = Supabase.instance.client.auth.currentUser;
      final metaAvatar = user?.userMetadata is Map
          ? ((user!.userMetadata as Map)['avatar_url'] as String? ?? '')
          : '';
      final metaName = user?.userMetadata is Map
          ? ((user!.userMetadata as Map)['full_name'] as String? ?? '')
          : '';

      if (!mounted) return;
      setState(() {
        _userAvatarUrl =
            (offline?['avatar_url'] as String? ?? metaAvatar).trim();
        _userName = (offline?['full_name'] as String? ?? metaName).trim();
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    try {
      setState(() {
        _loading = true;
        _error = '';
      });
      final data = await WeatherService.current;
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
      // Reset and replay animation
      _fadeCtrl.reset();
      _slideCtrl.reset();
      _fadeCtrl.forward();
      _slideCtrl.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '';
        _loading = false;
        // On error, still show content with default values
      });
    }
  }


  void _onRefreshTap() {
    HapticFeedback.lightImpact();
    _loadWeather();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final cardShadow = isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0x0A000000);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200;
    final viewAllColor = isDark ? const Color(0xFF22C55E) : const Color(0xFF0F766E);

    return Scaffold(
      backgroundColor: bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF067A46)))
          : _error.isNotEmpty
              ? _errorView(isDark, textColor, subColor)
              : RefreshIndicator(
                  onRefresh: () async {
                    _onRefreshTap();
                  },
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          SliverToBoxAdapter(child: _buildHeader(isDark, textColor, subColor)),
                          const SliverToBoxAdapter(child: SizedBox(height: 12)),
                          SliverToBoxAdapter(child: _buildMainCard()),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                          SliverToBoxAdapter(child: _buildQuickAccess(isDark, textColor, subColor, cardBg, cardShadow, viewAllColor)),
                          const SliverToBoxAdapter(child: SizedBox(height: 20)),
                          SliverToBoxAdapter(child: _buildLatestAlerts(isDark, textColor, subColor, cardBg, cardShadow, dividerColor, viewAllColor)),
                          const SliverToBoxAdapter(child: SizedBox(height: 20)),
                          SliverToBoxAdapter(child: _buildNetworkStatus(isDark, textColor, cardBg, cardShadow, viewAllColor)),
                          const SliverToBoxAdapter(child: SizedBox(height: 20)),
                          SliverToBoxAdapter(child: _buildEmergencySOS()),
                          const SliverToBoxAdapter(child: SizedBox(height: 32)),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _errorView(bool isDark, Color textColor, Color subColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 52, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'Could not load weather',
              style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: textColor),
            ),
            const SizedBox(height: 6),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 13, color: subColor),
            ),
            const SizedBox(height: 18),
            TextButton.icon(
              onPressed: _loadWeather,
              icon: Icon(Icons.refresh_rounded, color: isDark ? const Color(0xFF22C55E) : const Color(0xFF0F766E)),
              label: Text('Retry', style: TextStyle(color: isDark ? const Color(0xFF22C55E) : const Color(0xFF0F766E))),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Header matching picture: Logo + text on left, bell + profile on right
  // ─────────────────────────────────────────────
  Widget _buildHeader(bool isDark, Color textColor, Color subColor) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.landscape_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GB CONNECT',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF047857),
                      letterSpacing: 0.5,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Stay Connected, Stay Safe',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: subColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => widget.onNavigateTab?.call(2),
              icon: Icon(Icons.notifications_none_rounded, color: textColor),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(showBackButton: true),
                  ),
                );
                _loadUserProfile();
              },
              child: AvatarWidget(
                avatarUrl: _userAvatarUrl,
                name: _userName,
                size: 36,
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunCloudGraphic() {
    return SizedBox(
      width: 100,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 1. Glowing Sun (BEHIND at top-left)
          Positioned(
            top: 0,
            left: 8,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFFFE082),
                    Color(0xFFFF8F00),
                  ],
                  stops: [0.2, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8F00).withValues(alpha: 0.6),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          // 2. 3D Puffy Cloud (IN FRONT at bottom-right)
          Positioned(
            bottom: 5,
            right: 0,
            child: SizedBox(
              width: 76,
              height: 50,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Shadow for the cloud
                  Positioned(
                    bottom: -2,
                    left: 4,
                    right: 4,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 12,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Left small puff
                  Positioned(
                    bottom: 10,
                    left: 6,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Right main puff
                  Positioned(
                    bottom: 12,
                    right: 14,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Color(0xFFF1F5F9)],
                        ),
                      ),
                    ),
                  ),
                  // Bottom Base of Cloud
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Color(0xFFE2E8F0)],
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

  // ─────────────────────────────────────────────
  // Main Weather Card (Mountain BG + Temp + Stats overlay bar)
  // ─────────────────────────────────────────────
  Widget _buildMainCard() {
    final cur = _data?.current;
    final temp = cur?.temperatureC.round().toString() ?? '18';
    final cond = cur?.conditionText ?? 'Partly Cloudy';
    final hum = cur?.humidity.toString() ?? '37';
    final wind = cur?.windKmh.toStringAsFixed(0) ?? '12';
    final pres = cur?.pressureHpa.toString() ?? '1012';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => widget.onNavigateTab?.call(1),
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x20000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AppImages.weatherImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      AppImages.homeImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Gilgit, Pakistan',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'View Full Forecast',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.scale(
                              scale: 0.8,
                              alignment: Alignment.centerLeft,
                              child: _buildSunCloudGraphic(),
                            ),
                            const SizedBox(width: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$temp°',
                                  style: GoogleFonts.outfit(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, left: 4),
                                  child: Text(
                                    'C',
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  cond,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _weatherStatMini(Icons.water_drop_outlined, '$hum%', 'Humidity'),
                            Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.3)),
                            _weatherStatMini(Icons.air_rounded, '$wind km/h', 'Wind'),
                            Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.3)),
                            _weatherStatMini(Icons.speed_rounded, '$pres hPa', 'Pressure'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _weatherStatMini(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Section Header
  // ─────────────────────────────────────────────
  Widget _buildSectionHeader(String title, Color textColor, Color viewAllColor, {VoidCallback? onViewAll}) {
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
              color: textColor,
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: viewAllColor,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: viewAllColor, size: 16),
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
  Widget _buildQuickAccess(bool isDark, Color textColor, Color subColor, Color cardBg, Color cardShadow, Color viewAllColor) {
    final qaBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final qaShadow = isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0x0A000000);
    final qaLabel = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quick Access', textColor, viewAllColor),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickAccessItem(
                Icons.cloud_rounded,
                'Weather',
                const Color(0xFF3B82F6),
                qaBg,
                qaShadow,
                qaLabel,
                onTap: () => widget.onNavigateTab?.call(1),
              ),
              _buildQuickAccessItem(
                Icons.warning_rounded,
                'Alerts',
                const Color(0xFFEF4444),
                qaBg,
                qaShadow,
                qaLabel,
                onTap: () => widget.onNavigateTab?.call(2),
              ),
              _buildQuickAccessItem(
                Icons.cell_tower_rounded,
                'Network',
                const Color(0xFF22C55E),
                qaBg,
                qaShadow,
                qaLabel,
                onTap: () => widget.onNavigateTab?.call(3),
              ),
              _buildQuickAccessItem(
                Icons.sos_rounded,
                'SOS',
                const Color(0xFFEF4444),
                qaBg,
                qaShadow,
                qaLabel,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SOSSenderScreen()),
                ),
              ),
              _buildQuickAccessItem(
                Icons.person_rounded,
                'Profile',
                const Color(0xFF8B5CF6),
                qaBg,
                qaShadow,
                qaLabel,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(showBackButton: true),
                    ),
                  );
                  _loadUserProfile();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(IconData icon, String label, Color color, Color bg, Color shadow, Color labelColor, {String? badge, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: shadow, blurRadius: 10, offset: const Offset(0, 4)),
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
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Latest Alerts
  // ─────────────────────────────────────────────
  Widget _buildLatestAlerts(bool isDark, Color textColor, Color subColor, Color cardBg, Color cardShadow, Color dividerColor, Color viewAllColor) {
    return Column(
      children: [
        _buildSectionHeader('Latest Alerts', textColor, viewAllColor, onViewAll: () => widget.onNavigateTab?.call(2)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: cardShadow, blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                _buildAlertItem(
                  icon: Icons.landslide_rounded,
                  iconColor: const Color(0xFFEF4444),
                  title: 'Landslide Warning',
                  location: 'Hunza, Gilgit-Baltistan',
                  timeAgo: '2h ago',
                  textColor: textColor,
                  subColor: subColor,
                  chevronColor: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                  onTap: () => widget.onNavigateTab?.call(2),
                ),
                Divider(height: 1, color: dividerColor, indent: 64),
                _buildAlertItem(
                  icon: Icons.flood_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Flood Advisory',
                  location: 'Ghizer, Gilgit-Baltistan',
                  timeAgo: '5h ago',
                  textColor: textColor,
                  subColor: subColor,
                  chevronColor: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                  onTap: () => widget.onNavigateTab?.call(2),
                ),
                Divider(height: 1, color: dividerColor, indent: 64),
                _buildAlertItem(
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Road Closed',
                  location: 'Babusar Top, Naran Road',
                  timeAgo: '1d ago',
                  textColor: textColor,
                  subColor: subColor,
                  chevronColor: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                  onTap: () => widget.onNavigateTab?.call(2),
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
    required Color textColor,
    required Color subColor,
    required Color chevronColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
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
                      color: textColor,
                    ),
                  ),
                  Text(
                    location,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subColor,
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
                Icon(Icons.chevron_right_rounded, color: chevronColor, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Network Status
  // ─────────────────────────────────────────────
  Widget _buildNetworkStatus(bool isDark, Color textColor, Color cardBg, Color cardShadow, Color viewAllColor) {
    final nameColor = isDark ? Colors.white : const Color(0xFF334155);
    final barBgColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    return Column(
      children: [
        _buildSectionHeader('Network Status', textColor, viewAllColor, onViewAll: () => widget.onNavigateTab?.call(3)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () => widget.onNavigateTab?.call(3),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: cardShadow, blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNetworkItem('SCOM', AppImages.scomIcon, const Color(0xFF22C55E), 4, nameColor, barBgColor),
                  _buildNetworkItem('Jazz', AppImages.jazzIcon, const Color(0xFF22C55E), 4, nameColor, barBgColor),
                  _buildNetworkItem('Zong 4G', AppImages.zongIcon, const Color(0xFF22C55E), 4, nameColor, barBgColor),
                  _buildNetworkItem('Telenor', AppImages.telenorIcon, const Color(0xFFF59E0B), 2, nameColor, barBgColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkItem(String name, String imageAssetPath, Color statusColor, int bars, Color nameColor, Color barBgColor) {
    return Column(
      children: [
        SizedBox(
          height: 36,
          width: 50,
          child: Image.asset(
            imageAssetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.cell_tower_rounded, color: statusColor, size: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: nameColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3.5,
              height: 6.0 + (index * 2.5),
              decoration: BoxDecoration(
                color: index < bars ? statusColor : barBgColor,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          bars == 4 ? 'Good' : 'Fair',
          style: GoogleFonts.outfit(
            fontSize: 10,
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
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SOSSenderScreen()),
        ),
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
                      'Emergency SOS',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to send your location to emergency contacts',
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
                      'Send SOS',
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
      ),
    );
  }

}
