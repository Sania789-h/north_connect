import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_images.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  int _selectedHourIndex = 0;

  final List<Map<String, dynamic>> _hourly = [
    {'time': 'Now',   'icon': Icons.cloud_rounded,      'temp': '18°', 'color': Color(0xFF64748B)},
    {'time': '11 AM', 'icon': Icons.wb_cloudy_rounded,  'temp': '19°', 'color': Color(0xFF94A3B8)},
    {'time': '12 PM', 'icon': Icons.cloud_rounded,      'temp': '20°', 'color': Color(0xFF64748B)},
    {'time': '1 PM',  'icon': Icons.wb_sunny_rounded,   'temp': '21°', 'color': Color(0xFFFBBF24)},
    {'time': '2 PM',  'icon': Icons.wb_sunny_rounded,   'temp': '22°', 'color': Color(0xFFF59E0B)},
    {'time': '3 PM',  'icon': Icons.wb_cloudy_rounded,  'temp': '22°', 'color': Color(0xFF94A3B8)},
  ];

  final List<Map<String, dynamic>> _daily = [
    {'day': 'Thursday', 'icon': Icons.wb_sunny_rounded,  'iconColor': Color(0xFFFBBF24), 'high': '23°', 'low': '12°'},
    {'day': 'Friday',   'icon': Icons.wb_sunny_rounded,  'iconColor': Color(0xFFF59E0B), 'high': '24°', 'low': '13°'},
    {'day': 'Saturday', 'icon': Icons.wb_cloudy_rounded, 'iconColor': Color(0xFF94A3B8), 'high': '25°', 'low': '14°'},
    {'day': 'Sunday',   'icon': Icons.wb_sunny_rounded,  'iconColor': Color(0xFFFBBF24), 'high': '22°', 'low': '11°'},
    {'day': 'Monday',   'icon': Icons.cloud_rounded,     'iconColor': Color(0xFF64748B), 'high': '21°', 'low': '10°'},
  ];

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

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _onHourTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedHourIndex = index);
    final item = _hourly[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => _HourDetailSheet(
        time: item['time'] as String,
        temp: item['temp'] as String,
        icon: item['icon'] as IconData,
        color: item['color'] as Color,
      ),
    );
  }

  void _onDayTap(Map<String, dynamic> day) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => _DayDetailSheet(day: day),
    );
  }

  void _onAirQualityTap() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => const _AirQualitySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App Bar ──
              SliverToBoxAdapter(child: _buildHeader()),

              // ── Main Weather Card ──
              SliverToBoxAdapter(child: _buildMainCard()),

              SliverToBoxAdapter(child: const SizedBox(height: 22)),

              // ── Today's Forecast ──
              SliverToBoxAdapter(child: _buildSectionTitle("Today's Forecast")),
              SliverToBoxAdapter(child: const SizedBox(height: 10)),
              SliverToBoxAdapter(child: _buildHourlyRow()),

              SliverToBoxAdapter(child: const SizedBox(height: 22)),

              // ── 5-Day Forecast ──
              SliverToBoxAdapter(child: _buildDailyCard()),

              SliverToBoxAdapter(child: const SizedBox(height: 16)),

              // ── Air Quality ──
              SliverToBoxAdapter(child: _buildAirQuality()),

              SliverToBoxAdapter(child: const SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 8,
                        offset: Offset(0, 2))
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Weather',
                    style: GoogleFonts.outfit(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 13, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 3),
                      Text(
                        'Gilgit, Pakistan',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 2))
                ],
              ),
              child: const Icon(Icons.refresh_rounded,
                  size: 20, color: Color(0xFF3B82F6)),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildMainCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x401B547A),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 290,
                child: Image.asset(
                  AppImages.weatherImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF1B547A),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(top: 18, left: 4),
                                child: Icon(
                                  Icons.cloud_rounded,
                                  color: Colors.white,
                                  size: 64,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x77000000),
                                      blurRadius: 14,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 2,
                                left: 20,
                                child: Icon(
                                  Icons.wb_sunny_rounded,
                                  color: Color(0xFFFFC83D),
                                  size: 44,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x66000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '18',
                                      style: GoogleFonts.outfit(
                                        fontSize: 80,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 0.95,
                                        shadows: const [
                                          Shadow(
                                            color: Color(0x77000000),
                                            blurRadius: 14,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(
                                        '°C',
                                        style: GoogleFonts.outfit(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                          shadows: const [
                                            Shadow(
                                              color: Color(0x77000000),
                                              blurRadius: 14,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Partly Cloudy',
                                  style: GoogleFonts.outfit(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0x77000000),
                                        blurRadius: 14,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F000000),
                              blurRadius: 18,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _weatherStatLight(
                              icon: Icons.water_drop_rounded,
                              value: '37%',
                              label: 'Humidity',
                            ),
                            Container(
                              width: 1,
                              height: 34,
                              color: const Color(0xFFE2E8F0),
                            ),
                            _weatherStatLight(
                              icon: Icons.air_rounded,
                              value: '12 km/h',
                              label: 'Wind',
                            ),
                            Container(
                              width: 1,
                              height: 34,
                              color: const Color(0xFFE2E8F0),
                            ),
                            _weatherStatLight(
                              icon: Icons.gps_fixed_rounded,
                              value: '1012 hPa',
                              label: 'Pressure',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weatherStatLight({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF334155)),
              const SizedBox(width: 6),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.92)),
              const SizedBox(width: 6),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildHourlyRow() {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _hourly.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = _hourly[i];
          final bool selected = i == _selectedHourIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 66,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF1B547A)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? const Color(0x401B547A)
                      : const Color(0x10000000),
                  blurRadius: selected ? 10 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onHourTap(i),
                borderRadius: BorderRadius.circular(18),
                splashColor: (selected
                        ? Colors.white
                        : const Color(0xFF1B547A))
                    .withValues(alpha: 0.15),
                highlightColor: (selected
                        ? Colors.white
                        : const Color(0xFF1B547A))
                    .withValues(alpha: 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['time'],
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: selected
                            ? const Color(0xCCFFFFFF)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(
                      item['icon'] as IconData,
                      size: 22,
                      color: selected
                          ? Colors.white
                          : (item['color'] as Color),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['temp'],
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildDailyCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0E000000), blurRadius: 10, offset: Offset(0, 3))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: List.generate(_daily.length, (i) {
            final item = _daily[i];
            final isLast = i == _daily.length - 1;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onDayTap(item),
                splashColor: const Color(0xFF1B547A).withValues(alpha: 0.08),
                highlightColor:
                    const Color(0xFF1B547A).withValues(alpha: 0.04),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              item['day'],
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            item['icon'] as IconData,
                            size: 28,
                            color: item['iconColor'] as Color,
                          ),
                          const Spacer(),
                          Text(
                            item['high'],
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item['low'],
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded,
                              size: 18, color: Color(0xFFCBD5E1)),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Color(0xFFF1F5F9)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildAirQuality() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0E000000),
              blurRadius: 10,
              offset: Offset(0, 3))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _onAirQualityTap,
            splashColor: const Color(0xFF22C55E).withValues(alpha: 0.08),
            highlightColor:
                const Color(0xFF22C55E).withValues(alpha: 0.04),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF22C55E).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco_rounded,
                        color: Color(0xFF22C55E), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Air Quality',
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: const Color(0xFF64748B))),
                        Text('Good',
                            style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF22C55E))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('32 AQI',
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A))),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8), size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// Hour Detail Bottom Sheet
// ═══════════════════════════════════════════════
class _HourDetailSheet extends StatelessWidget {
  final String time;
  final String temp;
  final IconData icon;
  final Color color;

  const _HourDetailSheet({
    required this.time,
    required this.temp,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 20),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 46, color: color),
          ),
          const SizedBox(height: 14),
          Text(time,
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text('Gilgit, Pakistan',
              style: GoogleFonts.outfit(
                  fontSize: 13, color: const Color(0xFF64748B))),
          const SizedBox(height: 14),
          Text(temp,
              style: GoogleFonts.outfit(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoTile2(Icons.water_drop_outlined, '38%', 'Humidity'),
              _infoTile2(Icons.air_rounded, '11 km/h', 'Wind'),
              _infoTile2(Icons.light_mode_rounded, '5', 'UV Index'),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoTile2(IconData icon, String val, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 22, color: const Color(0xFF1B547A)),
        ),
        const SizedBox(height: 6),
        Text(val,
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B))),
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 11, color: const Color(0xFF94A3B8))),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// Day Detail Bottom Sheet
// ═══════════════════════════════════════════════
class _DayDetailSheet extends StatelessWidget {
  final Map<String, dynamic> day;
  const _DayDetailSheet({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 20),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: (day['iconColor'] as Color).withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(day['icon'] as IconData,
                size: 48, color: day['iconColor'] as Color),
          ),
          const SizedBox(height: 14),
          Text(day['day'],
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text('Gilgit, Pakistan',
              style: GoogleFonts.outfit(
                  fontSize: 13, color: const Color(0xFF64748B))),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(day['high'],
                  style: GoogleFonts.outfit(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B))),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('/  ${day['low']}',
                    style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoTile(Icons.water_drop_outlined, '42%', 'Humidity'),
              _infoTile(Icons.air_rounded, '14 km/h', 'Wind'),
              _infoTile(Icons.umbrella_rounded, '10%', 'Rain'),
              _infoTile(Icons.light_mode_rounded, '6', 'UV'),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String val, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 22, color: const Color(0xFF1B547A)),
        ),
        const SizedBox(height: 6),
        Text(val,
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B))),
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 11, color: const Color(0xFF94A3B8))),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// Air Quality Bottom Sheet
// ═══════════════════════════════════════════════
class _AirQualitySheet extends StatelessWidget {
  const _AirQualitySheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded,
                color: Color(0xFF22C55E), size: 34),
          ),
          const SizedBox(height: 12),
          Text('Air Quality Index',
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text('Gilgit, Pakistan',
              style: GoogleFonts.outfit(
                  fontSize: 13, color: const Color(0xFF64748B))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('32 AQI',
                      style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF16A34A))),
                  Text('Good',
                      style: GoogleFonts.outfit(
                          fontSize: 14, color: const Color(0xFF22C55E))),
                ]),
                const Icon(Icons.eco_rounded,
                    size: 48, color: Color(0xFF22C55E)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _aqiTile('PM2.5', '12 µg/m³'),
              _aqiTile('PM10',  '24 µg/m³'),
              _aqiTile('O₃',    '38 ppb'),
              _aqiTile('NO₂',   '8 ppb'),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _aqiTile(String label, String val) {
    return Column(
      children: [
        Text(val,
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B))),
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 11, color: const Color(0xFF94A3B8))),
      ],
    );
  }
}
