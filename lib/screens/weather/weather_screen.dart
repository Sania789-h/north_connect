import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_images.dart';
import '../../services/weather_service.dart';

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

  bool _loading = true;
  String _error = '';
  WeatherData? _data;

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

    _loadWeather();
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
      _fadeCtrl.forward();
      _slideCtrl.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  IconData _conditionIcon(WeatherCondition c, {bool outlined = false}) {
    switch (c) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny_rounded;
      case WeatherCondition.partlyCloudy:
        return outlined ? Icons.wb_cloudy_outlined : Icons.wb_cloudy_rounded;
      case WeatherCondition.cloudy:
        return outlined ? Icons.cloud_outlined : Icons.cloud_rounded;
      case WeatherCondition.rainy:
        return outlined ? Icons.grain_outlined : Icons.water_drop_rounded;
      case WeatherCondition.stormy:
        return Icons.thunderstorm_rounded;
      case WeatherCondition.snowy:
        return outlined ? Icons.ac_unit_outlined : Icons.ac_unit_rounded;
      case WeatherCondition.foggy:
        return Icons.cloud_rounded;
      case WeatherCondition.windy:
        return Icons.air_rounded;
    }
  }

  Color _conditionColor(WeatherCondition c) {
    switch (c) {
      case WeatherCondition.sunny:
        return const Color(0xFFFFB020);
      case WeatherCondition.partlyCloudy:
        return const Color(0xFF94A3B8);
      case WeatherCondition.cloudy:
        return const Color(0xFF64748B);
      case WeatherCondition.rainy:
        return const Color(0xFF3B82F6);
      case WeatherCondition.stormy:
        return const Color(0xFF7C3AED);
      case WeatherCondition.snowy:
        return const Color(0xFF06B6D4);
      case WeatherCondition.foggy:
        return const Color(0xFF9CA3AF);
      case WeatherCondition.windy:
        return const Color(0xFF14B8A6);
    }
  }

  String _fmtT(double v) => '${v.round()}°';

  void _onRefreshTap() {
    HapticFeedback.lightImpact();
    _loadWeather();
  }

  void _onHourTap(int index) {
    if (_data == null) return;
    HapticFeedback.selectionClick();
    final item = _data!.hourly[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => _HourDetailSheet(
        time: item.timeLabel,
        temp: _fmtT(item.tempC),
        icon: _conditionIcon(item.condition),
        color: _conditionColor(item.condition),
        humidity: '${item.humidity}%',
        wind: '${item.windKmh.toStringAsFixed(0)} km/h',
        uv: item.uvIndex.toString(),
        rain: '${item.rainChance}%',
      ),
    );
  }

  void _onDayTap(DailyForecast day) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => _DayDetailSheet(
        title: day.dayName,
        high: _fmtT(day.maxTempC),
        low: _fmtT(day.minTempC),
        icon: _conditionIcon(day.condition),
        color: _conditionColor(day.condition),
        humidity: '${day.humidity}%',
        wind: '${day.windKmh.toStringAsFixed(0)} km/h',
        rain: '${day.rainChance}%',
        uv: day.uvIndex.toString(),
        sunrise: day.sunrise,
        sunset: day.sunset,
      ),
    );
  }

  void _onAirQualityTap() {
    if (_data == null) return;
    HapticFeedback.lightImpact();
    final a = _data!.airQuality;
    final Color aqiColor;
    if (a.aqi <= 50) {
      aqiColor = const Color(0xFF22C55E);
    } else if (a.aqi <= 100) {
      aqiColor = const Color(0xFFF59E0B);
    } else if (a.aqi <= 150) {
      aqiColor = const Color(0xFFF97316);
    } else {
      aqiColor = const Color(0xFFEF4444);
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => _AirQualitySheet(
        aqi: a.aqi,
        level: a.level,
        levelText: a.levelText,
        color: aqiColor,
        pm2_5: a.pm2_5,
        pm10: a.pm10,
        o3: a.o3,
        no2: a.no2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: () async => _onRefreshTap(),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          // ── Sticky + Parallax Image Header ──
                          SliverAppBar(
                            pinned: true,
                            snap: false,
                            floating: false,
                            expandedHeight: 340,
                            collapsedHeight: kToolbarHeight + top,
                            backgroundColor: const Color(0xFF1E3C72),
                            elevation: 0,
                            leadingWidth: 56,
                            leading: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: GestureDetector(
                                onTap: () => Navigator.maybePop(context),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            title: LayoutBuilder(
                              builder: (ctx, cons) {
                                final settings =
                                    ctx.dependOnInheritedWidgetOfExactType<
                                            FlexibleSpaceBarSettings>() ??
                                        dummyFlexibleSettings;
                                final ext = settings.currentExtent;
                                final minExt = settings.minExtent;
                                final maxExt = settings.maxExtent;
                                final t = ((ext - minExt) /
                                        (maxExt - minExt))
                                    .clamp(0.0, 1.0);
                                final isCollapsed = t < 0.3;
                                return AnimatedOpacity(
                                  duration: const Duration(milliseconds: 120),
                                  opacity: isCollapsed ? 1.0 : 0.0,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Weather',
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        _data?.current.locationName ?? '',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.85),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            centerTitle: true,
                            flexibleSpace: FlexibleSpaceBar(
                              collapseMode: CollapseMode.parallax,
                              background: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    AppImages.weatherImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF1E3C72),
                                            Color(0xFF2A5298)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.18),
                                          Colors.black.withValues(alpha: 0.15),
                                          Colors.black.withValues(alpha: 0.55),
                                        ],
                                        stops: const [0.0, 0.55, 1.0],
                                      ),
                                    ),
                                  ),
                                  SafeArea(
                                    bottom: false,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 56, 20, 28),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Weather',
                                            style: GoogleFonts.outfit(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              height: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _data?.current.locationName ??
                                                    'Gilgit, Pakistan',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          _MainCardOverlay(data: _data!),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Rest of the content ──
                          const SliverToBoxAdapter(
                              child: SizedBox(height: 22)),
                          SliverToBoxAdapter(
                              child: _buildSectionTitle("Today's Forecast")),
                          const SliverToBoxAdapter(child: SizedBox(height: 14)),
                          SliverToBoxAdapter(child: _buildHourlyRow()),
                          const SliverToBoxAdapter(child: SizedBox(height: 20)),
                          SliverToBoxAdapter(child: _buildDailyCard()),
                          const SliverToBoxAdapter(child: SizedBox(height: 20)),
                          SliverToBoxAdapter(child: _buildAirQuality()),
                          const SliverToBoxAdapter(child: SizedBox(height: 40)),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  // Dummy fallback so LayoutBuilder has required settings (null-safe fallback)
  FlexibleSpaceBarSettings get dummyFlexibleSettings {
    return FlexibleSpaceBarSettings(
      toolbarOpacity: 1,
      minExtent: kToolbarHeight + MediaQuery.of(context).padding.top,
      maxExtent: 340,
      currentExtent: 340,
      child: const SizedBox.shrink(),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 52, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'Could not load weather',
              style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 13, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            TextButton.icon(
              onPressed: _loadWeather,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildHourlyRow() {
    final items = _data!.hourly;
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final item = items[i];
          final color = _conditionColor(item.condition);
          final isNow = i == 0;
          return GestureDetector(
            onTap: () => _onHourTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 62,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isNow ? const Color(0xFF1E3C72) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.timeLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isNow
                          ? Colors.white.withValues(alpha: 0.85)
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    _conditionIcon(item.condition),
                    size: 26,
                    color: isNow ? Colors.white : color,
                  ),
                  Text(
                    _fmtT(item.tempC),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color:
                          isNow ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyCard() {
    final days = _data!.daily;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: List.generate(days.length, (i) {
            final item = days[i];
            final color = _conditionColor(item.condition);
            final isToday = i == 0;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onDayTap(item),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            Text(
                              isToday ? 'Today' : item.dayName,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF1E3C72).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Daily',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E3C72),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        _conditionIcon(item.condition),
                        size: 24,
                        color: item.condition == WeatherCondition.sunny
                            ? const Color(0xFFFFB020)
                            : color,
                      ),
                      const Spacer(flex: 3),
                      Text(
                        _fmtT(item.maxTempC),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _fmtT(item.minTempC),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAirQuality() {
    final a = _data!.airQuality;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _onAirQualityTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Air Quality',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFF007AFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_run_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        a.level,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${a.aqi} AQI',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ],
                  ),
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
// Main overlay shown inside the flexible image header
// ═══════════════════════════════════════════════
class _MainCardOverlay extends StatelessWidget {
  final WeatherData data;
  const _MainCardOverlay({required this.data});

  @override
  Widget build(BuildContext context) {
    final cur = data.current;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _staticConditionIcon(cur.condition),
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cur.conditionText,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${cur.temperatureC.round()}°C',
                      style: GoogleFonts.outfit(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Daily',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat(
                    Icons.water_drop_outlined,
                    '${cur.humidity}%',
                    'Humidity'),
                _vDivider(),
                _stat(
                    Icons.air_rounded,
                    '${cur.windKmh.toStringAsFixed(0)} km/h',
                    'Wind'),
                _vDivider(),
                _stat(
                    Icons.speed_rounded,
                    '${cur.pressureHpa}',
                    'Pressure'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 28,
        color: Colors.white.withValues(alpha: 0.22),
      );

  Widget _stat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _staticConditionIcon(WeatherCondition c) {
    switch (c) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny_rounded;
      case WeatherCondition.partlyCloudy:
        return Icons.wb_cloudy_rounded;
      case WeatherCondition.cloudy:
        return Icons.cloud_rounded;
      case WeatherCondition.rainy:
        return Icons.water_drop_rounded;
      case WeatherCondition.stormy:
        return Icons.thunderstorm_rounded;
      case WeatherCondition.snowy:
        return Icons.ac_unit_rounded;
      case WeatherCondition.foggy:
        return Icons.cloud_rounded;
      case WeatherCondition.windy:
        return Icons.air_rounded;
    }
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
  final String humidity;
  final String wind;
  final String uv;
  final String rain;

  const _HourDetailSheet({
    required this.time,
    required this.temp,
    required this.icon,
    required this.color,
    required this.humidity,
    required this.wind,
    required this.uv,
    required this.rain,
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
              _infoTile2(Icons.water_drop_outlined, humidity, 'Humidity'),
              _infoTile2(Icons.air_rounded, wind, 'Wind'),
              _infoTile2(Icons.light_mode_rounded, uv, 'UV Index'),
              _infoTile2(Icons.umbrella_rounded, rain, 'Rain'),
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
  final String title;
  final String high;
  final String low;
  final IconData icon;
  final Color color;
  final String humidity;
  final String wind;
  final String rain;
  final String uv;
  final String sunrise;
  final String sunset;

  const _DayDetailSheet({
    required this.title,
    required this.high,
    required this.low,
    required this.icon,
    required this.color,
    required this.humidity,
    required this.wind,
    required this.rain,
    required this.uv,
    required this.sunrise,
    required this.sunset,
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
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 14),
          Text(title,
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
              Text(high,
                  style: GoogleFonts.outfit(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B))),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('/  $low',
                    style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8))),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _miniInfo(Icons.wb_sunny_rounded, sunrise, 'Sunrise'),
              _miniInfo(Icons.nights_stay_rounded, sunset, 'Sunset'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoTile(Icons.water_drop_outlined, humidity, 'Humidity'),
              _infoTile(Icons.air_rounded, wind, 'Wind'),
              _infoTile(Icons.umbrella_rounded, rain, 'Rain'),
              _infoTile(Icons.light_mode_rounded, uv, 'UV'),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _miniInfo(IconData icon, String val, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(val,
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B))),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 11, color: const Color(0xFF94A3B8))),
          ],
        ),
      ],
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
  final int aqi;
  final String level;
  final String levelText;
  final Color color;
  final int pm2_5;
  final int pm10;
  final int o3;
  final int no2;

  const _AirQualitySheet({
    required this.aqi,
    required this.level,
    required this.levelText,
    required this.color,
    required this.pm2_5,
    required this.pm10,
    required this.o3,
    required this.no2,
  });

  Color _lightBg() => color.withValues(alpha: 0.12);

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
            decoration: BoxDecoration(
              color: _lightBg(),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco_rounded, color: color, size: 34),
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
              color: _lightBg(),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$aqi AQI',
                      style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  Text(level,
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ]),
                Icon(Icons.eco_rounded, size: 48, color: color),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(levelText,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 12, color: const Color(0xFF64748B))),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _aqiTile('PM2.5', '$pm2_5 µg/m³'),
              _aqiTile('PM10', '$pm10 µg/m³'),
              _aqiTile('O₃', '$o3 ppb'),
              _aqiTile('NO₂', '$no2 ppb'),
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
