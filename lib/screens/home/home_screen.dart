import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/helpers.dart';
import '../../services/notification_service.dart';
import '../alerts/alerts_screen.dart';
import '../emergency/sos_screen.dart';
import '../network/network_screen.dart';
import '../notifications/notifications_screen.dart';
import '../weather/weather_screen.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService _notifService = NotificationService();
  int _unreadCount = 0;
  bool _notifLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    await _notifService.initialize();
    final count = await _notifService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
        _notifLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(context),
              const SizedBox(height: 18),
              _buildWeatherCard(context),
              const SizedBox(height: 22),
              _buildQuickAccessSection(context),
              const SizedBox(height: 24),
              _buildLatestAlertsSection(context),
              const SizedBox(height: 24),
              _buildNetworkStatusSection(context),
              const SizedBox(height: 24),
              _buildEmergencyBanner(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              AppImages.logo,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.landscape_rounded,
                color: Color(0xFF067A46),
                size: 26,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                  children: const [
                    TextSpan(
                      text: 'GB ',
                      style: TextStyle(color: Color(0xFF0F2C59)),
                    ),
                    TextSpan(
                      text: 'CONNECT',
                      style: TextStyle(color: Color(0xFF067A46)),
                    ),
                  ],
                ),
              ),
              Text(
                'Stay Connected, Stay Safe',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () async {
                await Helpers.push(context, const NotificationsScreen());
                _loadUnreadCount();
              },
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF1E293B),
                size: 26,
              ),
            ),
            if (_notifLoaded && _unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF8FAFC), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      _unreadCount > 9 ? '9+' : '$_unreadCount',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            if (widget.onNavigateTab != null) {
              widget.onNavigateTab!(4);
            }
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F2C59),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const ClipOval(
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0EA5E9),
            Color(0xFF0284C7),
            Color(0xFF1E3A8A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.terrain_rounded,
              size: 170,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Helpers.showSnackBar(
                            context, "Location set to Gilgit, Pakistan");
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Gilgit, Pakistan',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1);
                        } else {
                          Helpers.push(context, const WeatherScreen());
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'View Full Forecast',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      child: Stack(
                        alignment: Alignment.center,
                        children: const [
                          Icon(
                            Icons.wb_sunny_rounded,
                            color: Color(0xFFFFB703),
                            size: 44,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Icon(
                              Icons.cloud_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '18°C',
                          style: GoogleFonts.outfit(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Partly Cloudy',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(Icons.water_drop_outlined, '37%', 'Humidity'),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      _buildMetricItem(Icons.air_rounded, '12 km/h', 'Wind'),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      _buildMetricItem(Icons.speed_rounded, '1012 hPa', 'Pressure'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Access',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F2C59),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(1);
                }
              },
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: Color(0xFF0284C7),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickItem(
              customWidget: const Icon(
                Icons.wb_sunny_rounded,
                color: Color(0xFF38BDF8),
                size: 28,
              ),
              label: 'Weather',
              bgColor: const Color(0xFFF0F9FF),
              onTap: () {
                if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
              },
            ),
            _buildQuickItem(
              customWidget: const Icon(
                Icons.gpp_maybe_rounded,
                color: Color(0xFFEF4444),
                size: 28,
              ),
              label: 'Alerts',
              bgColor: const Color(0xFFFEF2F2),
              onTap: () {
                if (widget.onNavigateTab != null) widget.onNavigateTab!(2);
              },
            ),
            _buildQuickItem(
              customWidget: const Icon(
                Icons.cell_tower_rounded,
                color: Color(0xFF10B981),
                size: 28,
              ),
              label: 'Network',
              bgColor: const Color(0xFFECFDF5),
              onTap: () {
                if (widget.onNavigateTab != null) widget.onNavigateTab!(3);
              },
            ),
            _buildQuickItem(
              customWidget: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'SOS',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              label: 'SOS',
              bgColor: const Color(0xFFFEF2F2),
              onTap: () {
                Helpers.push(context, const SOSScreen());
              },
            ),
            _buildQuickItem(
              customWidget: const Icon(
                Icons.person_rounded,
                color: Color(0xFFA855F7),
                size: 28,
              ),
              label: 'Profile',
              bgColor: const Color(0xFFFAF5FF),
              onTap: () {
                if (widget.onNavigateTab != null) widget.onNavigateTab!(4);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickItem({
    required Widget customWidget,
    required String label,
    required Color bgColor,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: customWidget),
                  ),
                ),
              ),
              if (badge != null)
                Positioned(
                  right: -2,
                  top: -2,
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
                        fontWeight: FontWeight.bold,
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
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestAlertsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Latest Alerts',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F2C59),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(2);
                } else {
                  Helpers.push(context, const AlertsScreen());
                }
              },
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: Color(0xFF0284C7),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildAlertCard(
          context,
          icon: Icons.landscape_rounded,
          iconBgColor: const Color(0xFFEF4444),
          title: 'Landslide Warning',
          subtitle: 'Hunza, Gilgit-Baltistan',
          timeAgo: '2h ago',
          timeColor: const Color(0xFFEF4444),
        ),
        const SizedBox(height: 10),
        _buildAlertCard(
          context,
          icon: Icons.water_rounded,
          iconBgColor: const Color(0xFF0284C7),
          title: 'Flood Advisory',
          subtitle: 'Ghizer, Gilgit-Baltistan',
          timeAgo: '5h ago',
          timeColor: const Color(0xFF0284C7),
        ),
        const SizedBox(height: 10),
        _buildAlertCard(
          context,
          icon: Icons.alt_route_rounded,
          iconBgColor: const Color(0xFFF59E0B),
          title: 'Road Closed',
          subtitle: 'Babusar Top, Naran Road',
          timeAgo: '1d ago',
          timeColor: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String timeAgo,
    required Color timeColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (widget.onNavigateTab != null) {
            widget.onNavigateTab!(2);
          } else {
            Helpers.push(context, const AlertsScreen());
          }
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: iconBgColor.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F2C59),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
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
                      color: timeColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: timeColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkStatusSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Network Status',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F2C59),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(3);
                } else {
                  Helpers.push(context, const NetworkScreen());
                }
              },
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: Color(0xFF0284C7),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCarrierItem(
                logoWidget: const ScomLogo(),
                bars: 4,
                statusText: 'Good',
                isFair: false,
              ),
              _buildCarrierItem(
                logoWidget: const JazzLogo(),
                bars: 4,
                statusText: 'Good',
                isFair: false,
              ),
              _buildCarrierItem(
                logoWidget: const ZongLogo(),
                bars: 4,
                statusText: 'Good',
                isFair: false,
              ),
              _buildCarrierItem(
                logoWidget: const TelenorLogo(),
                bars: 2,
                statusText: 'Fair',
                isFair: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarrierItem({
    required Widget logoWidget,
    required int bars,
    required String statusText,
    required bool isFair,
  }) {
    final statusColor =
        isFair ? const Color(0xFFF59E0B) : const Color(0xFF2ECC71);

    return Column(
      children: [
        SizedBox(
          width: 44,
          height: 34,
          child: Center(child: logoWidget),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(4, (index) {
            final active = index < bars;
            final color = active ? statusColor : const Color(0xFFD1D5DB);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 4,
              height: (index + 1) * 3.5 + 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          statusText,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFEF4444),
            Color(0xFFDC2626),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: const [
                Icon(
                  Icons.phone_in_talk_rounded,
                  color: Color(0xFFDC2626),
                  size: 26,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency SOS',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
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
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Helpers.push(context, const SOSScreen());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'Send SOS',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFDC2626),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
