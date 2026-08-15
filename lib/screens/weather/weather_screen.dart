import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_images.dart';
import '../../core/utils/helpers.dart';
import '../../services/weather_service.dart';
import '../main_navigation_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() =>
      _WeatherScreenState();
}

class _WeatherScreenState
    extends State<WeatherScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  WeatherData? _data;

  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _loadWeather();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    try {
      setState(() {
        _loading = true;
        _error = '';
      });

      final result =
      await WeatherService.current;

      if (!mounted) return;

      setState(() {
        _data = result;
        _loading = false;
      });

      _fadeController
        ..reset()
        ..forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _refreshWeather() async {
    HapticFeedback.lightImpact();
    await _loadWeather();
  }

  IconData _conditionIcon(
      WeatherCondition condition,
      ) {
    switch (condition) {
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

  Color _conditionColor(
      WeatherCondition condition,
      ) {
    switch (condition) {
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

  String _temperature(double value) {
    return '${value.round()}°';
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final background =
    isDark
        ? const Color(0xFF0B1120)
        : const Color(0xFFF8FAFC);

    if (_loading) {
      return Scaffold(
        backgroundColor: background,
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1E3C72),
          ),
        ),
      );
    }

    if (_error.isNotEmpty ||
        _data == null) {
      return Scaffold(
        backgroundColor: background,
        body: _errorWidget(
          isDark,
        ),
      );
    }

    final data = _data!;

    return Scaffold(
      backgroundColor: background,
      body: RefreshIndicator(
        onRefresh: _refreshWeather,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [

              // =================================================
              // HEADER
              // =================================================

              SliverAppBar(
                pinned: true,
                expandedHeight: 330,
                backgroundColor:
                const Color(0xFF1E3C72),
                elevation: 0,

                leading: IconButton(
                  onPressed: () => Helpers.pop(
                    context,
                    fallbackPage: const MainNavigationScreen(),
                  ),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                title: Text(
                  'Weather',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                centerTitle: true,

                flexibleSpace:
                FlexibleSpaceBar(
                  collapseMode:
                  CollapseMode.parallax,

                  background: Stack(
                    fit: StackFit.expand,
                    children: [

                      Image.asset(
                        AppImages.weatherImage,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) {
                          return Container(
                            decoration:
                            const BoxDecoration(
                              gradient:
                              LinearGradient(
                                colors: [
                                  Color(
                                      0xFF1E3C72),
                                  Color(
                                      0xFF2A5298),
                                ],
                                begin:
                                Alignment.topLeft,
                                end:
                                Alignment.bottomRight,
                              ),
                            ),
                          );
                        },
                      ),

                      Container(
                        decoration:
                        BoxDecoration(
                          gradient:
                          LinearGradient(
                            begin:
                            Alignment.topCenter,
                            end:
                            Alignment.bottomCenter,
                            colors: [
                              Colors.black
                                  .withValues(
                                  alpha:
                                  0.15),
                              Colors.black
                                  .withValues(
                                  alpha:
                                  0.55),
                            ],
                          ),
                        ),
                      ),

                      SafeArea(
                        child: Padding(
                          padding:
                          const EdgeInsets
                              .fromLTRB(
                            20,
                            65,
                            20,
                            20,
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [

                              Text(
                                'Today',
                                style:
                                GoogleFonts
                                    .outfit(
                                  fontSize: 22,
                                  color:
                                  Colors.white,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),

                              const SizedBox(
                                  height: 3),

                              Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .location_on_rounded,
                                    color:
                                    Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(
                                      width: 4),
                                  Text(
                                    data.current
                                        .locationName,
                                    style:
                                    GoogleFonts
                                        .outfit(
                                      color: Colors
                                          .white
                                          .withValues(
                                          alpha:
                                          0.9),
                                      fontSize:
                                      13,
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              _currentWeatherCard(
                                data,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 22),
              ),

              // =================================================
              // HOURLY
              // =================================================

              SliverToBoxAdapter(
                child: _sectionTitle(
                  'Today\'s Hourly Forecast',
                  isDark,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 14),
              ),

              SliverToBoxAdapter(
                child: _hourlyForecast(
                  data,
                  isDark,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),

              // =================================================
              // 7 DAY FORECAST
              // =================================================

              SliverToBoxAdapter(
                child: _sectionTitle(
                  '7-Day Forecast',
                  isDark,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 14),
              ),

              SliverToBoxAdapter(
                child: _dailyForecast(
                  data,
                  isDark,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),

              // =================================================
              // AIR QUALITY
              // =================================================

              SliverToBoxAdapter(
                child: _airQuality(
                  data.airQuality,
                  isDark,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // CURRENT WEATHER CARD
  // ===========================================================

  Widget _currentWeatherCard(
      WeatherData data,
      ) {
    final current =
        data.current;

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white
            .withValues(alpha: 0.18),
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white
              .withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [

          Row(
            children: [

              Container(
                width: 58,
                height: 58,
                decoration:
                BoxDecoration(
                  color: Colors.white
                      .withValues(
                      alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _conditionIcon(
                    current.condition,
                  ),
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(
                  width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [

                    Text(
                      current.conditionText,
                      style:
                      GoogleFonts.outfit(
                        color: Colors.white
                            .withValues(
                            alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),

                    Text(
                      '${current.temperatureC.round()}°C',
                      style:
                      GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
              height: 14),

          Row(
            children: [

              _currentStat(
                Icons.water_drop_outlined,
                '${current.humidity}%',
                'Humidity',
              ),

              _divider(),

              _currentStat(
                Icons.air_rounded,
                '${current.windKmh.toStringAsFixed(0)} km/h',
                'Wind',
              ),

              _divider(),

              _currentStat(
                Icons.speed_rounded,
                '${current.pressureHpa.round()}',
                'Pressure',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currentStat(
      IconData icon,
      String value,
      String label,
      ) {
    return Expanded(
      child: Column(
        children: [

          Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),

          const SizedBox(
              height: 3),

          Text(
            value,
            style:
            GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          Text(
            label,
            style:
            GoogleFonts.outfit(
              color: Colors.white
                  .withValues(
                  alpha: 0.75),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white
          .withValues(alpha: 0.25),
    );
  }

  // ===========================================================
  // HOURLY FORECAST
  // ===========================================================

  Widget _hourlyForecast(
      WeatherData data,
      bool isDark,
      ) {
    final cardColor =
    isDark
        ? const Color(0xFF1E293B)
        : Colors.white;

    final textPrimary =
    isDark
        ? Colors.white
        : const Color(0xFF1E293B);

    final textSecondary =
    isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection:
        Axis.horizontal,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount:
        data.hourly.length,
        separatorBuilder:
            (_, __) =>
        const SizedBox(
            width: 12),
        itemBuilder:
            (context, index) {

          final item =
          data.hourly[index];

          final isNow =
              index == 0;

          return GestureDetector(
            onTap: () {
              HapticFeedback
                  .selectionClick();

              _showHourlyDetails(
                item,
                isDark,
              );
            },
            child: Container(
              width: 72,
              padding:
              const EdgeInsets
                  .symmetric(
                vertical: 10,
              ),
              decoration:
              BoxDecoration(
                color: isNow
                    ? const Color(
                    0xFF1E3C72)
                    : cardColor,
                borderRadius:
                BorderRadius
                    .circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(
                        alpha:
                        isDark
                            ? 0.2
                            : 0.06),
                    blurRadius: 8,
                    offset:
                    const Offset(
                        0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [

                  Text(
                    isNow
                        ? 'Now'
                        : item.timeLabel,
                    style:
                    GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w600,
                      color: isNow
                          ? Colors.white
                          : textSecondary,
                    ),
                  ),

                  Icon(
                    _conditionIcon(
                      item.condition,
                    ),
                    size: 26,
                    color: isNow
                        ? Colors.white
                        : _conditionColor(
                      item.condition,
                    ),
                  ),

                  Text(
                    _temperature(
                        item.tempC),
                    style:
                    GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w700,
                      color: isNow
                          ? Colors.white
                          : textPrimary,
                    ),
                  ),

                  Text(
                    '${item.rainChance}% rain',
                    style:
                    GoogleFonts.outfit(
                      fontSize: 9,
                      color: isNow
                          ? Colors.white
                          .withValues(
                          alpha:
                          0.75)
                          : textSecondary,
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

  // ===========================================================
  // 7 DAY FORECAST
  // ===========================================================

  Widget _dailyForecast(
      WeatherData data,
      bool isDark,
      ) {
    final cardColor =
    isDark
        ? const Color(0xFF1E293B)
        : Colors.white;

    final textPrimary =
    isDark
        ? Colors.white
        : const Color(0xFF1E293B);

    final textSecondary =
    isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Container(
        decoration:
        BoxDecoration(
          color: cardColor,
          borderRadius:
          BorderRadius.circular(
              20),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(
                  alpha:
                  isDark
                      ? 0.2
                      : 0.06),
              blurRadius: 10,
              offset:
              const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: List.generate(
            data.daily.length,
                (index) {

              final day =
              data.daily[index];

              final isToday =
                  index == 0;

              return Material(
                color:
                Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback
                        .selectionClick();

                    _showDayDetails(
                      day,
                      isDark,
                    );
                  },
                  child: Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [

                        SizedBox(
                          width: 86,
                          child: Text(
                            isToday
                                ? 'Today'
                                : day.dayName
                                .substring(
                                0,
                                3),
                            style:
                            GoogleFonts
                                .outfit(
                              fontWeight:
                              FontWeight
                                  .w700,
                              fontSize:
                              14,
                              color:
                              textPrimary,
                            ),
                          ),
                        ),

                        Icon(
                          _conditionIcon(
                              day.condition),
                          color:
                          _conditionColor(
                              day.condition),
                          size: 25,
                        ),

                        const SizedBox(
                            width: 12),

                        Expanded(
                          child: Text(
                            day.conditionText,
                            style:
                            GoogleFonts
                                .outfit(
                              fontSize:
                              12,
                              color:
                              textSecondary,
                            ),
                          ),
                        ),

                        Text(
                          '${day.maxTempC.round()}°',
                          style:
                          GoogleFonts
                              .outfit(
                            fontSize:
                            15,
                            fontWeight:
                            FontWeight
                                .w700,
                            color:
                            textPrimary,
                          ),
                        ),

                        const SizedBox(
                            width: 12),

                        Text(
                          '${day.minTempC.round()}°',
                          style:
                          GoogleFonts
                              .outfit(
                            fontSize:
                            14,
                            color:
                            textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // AIR QUALITY
  // ===========================================================

  Widget _airQuality(
      AirQuality air,
      bool isDark,
      ) {
    final cardColor =
    isDark
        ? const Color(0xFF1E293B)
        : Colors.white;

    final textPrimary =
    isDark
        ? Colors.white
        : const Color(0xFF1E293B);

    final textSecondary =
    isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);

    Color color;

    if (air.aqi <= 50) {
      color =
      const Color(0xFF22C55E);
    } else if (air.aqi <= 100) {
      color =
      const Color(0xFFF59E0B);
    } else if (air.aqi <= 150) {
      color =
      const Color(0xFFF97316);
    } else {
      color =
      const Color(0xFFEF4444);
    }

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Container(
        padding:
        const EdgeInsets.all(18),
        decoration:
        BoxDecoration(
          color: cardColor,
          borderRadius:
          BorderRadius.circular(
              20),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Text(
              'Air Quality',
              style:
              GoogleFonts.outfit(
                fontSize: 16,
                fontWeight:
                FontWeight.w700,
                color:
                textPrimary,
              ),
            ),

            const SizedBox(
                height: 14),

            Row(
              children: [

                Container(
                  width: 44,
                  height: 44,
                  decoration:
                  BoxDecoration(
                    color:
                    color.withValues(
                        alpha:
                        0.12),
                    shape:
                    BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: color,
                  ),
                ),

                const SizedBox(
                    width: 12),

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [

                    Text(
                      air.level,
                      style:
                      GoogleFonts
                          .outfit(
                        fontWeight:
                        FontWeight
                            .w700,
                        color:
                        textPrimary,
                      ),
                    ),

                    Text(
                      '${air.aqi} AQI',
                      style:
                      GoogleFonts
                          .outfit(
                        fontSize: 12,
                        color:
                        textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(
                height: 14),

            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [

                _airTile(
                  'PM2.5',
                  '${air.pm2_5}',
                  textPrimary,
                  textSecondary,
                ),

                _airTile(
                  'PM10',
                  '${air.pm10}',
                  textPrimary,
                  textSecondary,
                ),

                _airTile(
                  'O₃',
                  '${air.o3}',
                  textPrimary,
                  textSecondary,
                ),

                _airTile(
                  'NO₂',
                  '${air.no2}',
                  textPrimary,
                  textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _airTile(
      String label,
      String value,
      Color primary,
      Color secondary,
      ) {
    return Column(
      children: [

        Text(
          value,
          style:
          GoogleFonts.outfit(
            fontWeight:
            FontWeight.w700,
            color: primary,
          ),
        ),

        Text(
          label,
          style:
          GoogleFonts.outfit(
            fontSize: 10,
            color: secondary,
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // SECTION TITLE
  // ===========================================================

  Widget _sectionTitle(
      String title,
      bool isDark,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Text(
        title,
        style:
        GoogleFonts.outfit(
          fontSize: 18,
          fontWeight:
          FontWeight.w700,
          color: isDark
              ? Colors.white
              : const Color(
              0xFF1E293B),
        ),
      ),
    );
  }

  // ===========================================================
  // HOURLY DETAILS
  // ===========================================================

  void _showHourlyDetails(
      HourlyForecast item,
      bool isDark,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
      Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _DetailSheet(
          title: item.timeLabel,
          subtitle:
          'Gilgit, Pakistan',
          icon: _conditionIcon(
              item.condition),
          color: _conditionColor(
              item.condition),
          temperature:
          '${item.tempC.round()}°C',
          values: [
            ['Humidity',
              '${item.humidity}%'],
            ['Wind',
              '${item.windKmh.round()} km/h'],
            ['Rain',
              '${item.rainChance}%'],
            ['UV',
              item.uvIndex
                  .toStringAsFixed(1)],
          ],
        );
      },
    );
  }

  // ===========================================================
  // DAILY DETAILS
  // ===========================================================

  void _showDayDetails(
      DailyForecast day,
      bool isDark,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
      Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _DetailSheet(
          title: day.dayName,
          subtitle:
          'Gilgit, Pakistan',
          icon: _conditionIcon(
              day.condition),
          color: _conditionColor(
              day.condition),
          temperature:
          '${day.maxTempC.round()}° / ${day.minTempC.round()}°',
          values: [
            ['Humidity',
              '${day.humidity}%'],
            ['Wind',
              '${day.windKmh.round()} km/h'],
            ['Rain',
              '${day.rainChance}%'],
            ['UV',
              day.uvIndex
                  .toStringAsFixed(1)],
            ['Sunrise',
              day.sunrise],
            ['Sunset',
              day.sunset],
          ],
        );
      },
    );
  }

  // ===========================================================
  // ERROR
  // ===========================================================

  Widget _errorWidget(
      bool isDark,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [

            const Icon(
              Icons.cloud_off_rounded,
              size: 55,
              color:
              Color(0xFF94A3B8),
            ),

            const SizedBox(
                height: 14),

            Text(
              'Could not load weather',
              style:
              GoogleFonts.outfit(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
                color: isDark
                    ? Colors.white
                    : const Color(
                    0xFF1E293B),
              ),
            ),

            const SizedBox(
                height: 8),

            Text(
              _error,
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.outfit(
                fontSize: 12,
                color: isDark
                    ? const Color(
                    0xFFCBD5E1)
                    : const Color(
                    0xFF64748B),
              ),
            ),

            const SizedBox(
                height: 18),

            ElevatedButton.icon(
              onPressed:
              _loadWeather,
              icon: const Icon(
                  Icons.refresh),
              label:
              const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// DETAIL SHEET
// =============================================================

class _DetailSheet
    extends StatelessWidget {

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String temperature;
  final List<List<String>>
  values;

  const _DetailSheet({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.temperature,
    required this.values,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    final background =
    isDark
        ? const Color(0xFF1E293B)
        : Colors.white;

    final primary =
    isDark
        ? Colors.white
        : const Color(
        0xFF1E293B);

    final secondary =
    isDark
        ? const Color(
        0xFFCBD5E1)
        : const Color(
        0xFF64748B);

    return Container(
      margin:
      const EdgeInsets.all(12),
      padding:
      const EdgeInsets.all(24),
      decoration:
      BoxDecoration(
        color: background,
        borderRadius:
        BorderRadius.circular(
            24),
      ),
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [

          Container(
            width: 40,
            height: 4,
            decoration:
            BoxDecoration(
              color: isDark
                  ? const Color(
                  0xFF475569)
                  : const Color(
                  0xFFE2E8F0),
              borderRadius:
              BorderRadius.circular(
                  4),
            ),
          ),

          const SizedBox(
              height: 20),

          Container(
            width: 76,
            height: 76,
            decoration:
            BoxDecoration(
              color: color.withValues(
                  alpha: 0.12),
              shape:
              BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: color,
            ),
          ),

          const SizedBox(
              height: 14),

          Text(
            title,
            style:
            GoogleFonts.outfit(
              fontSize: 20,
              fontWeight:
              FontWeight.w700,
              color: primary,
            ),
          ),

          Text(
            subtitle,
            style:
            GoogleFonts.outfit(
              fontSize: 13,
              color: secondary,
            ),
          ),

          const SizedBox(
              height: 12),

          Text(
            temperature,
            style:
            GoogleFonts.outfit(
              fontSize: 38,
              fontWeight:
              FontWeight.w800,
              color: primary,
            ),
          ),

          const SizedBox(
              height: 20),

          Wrap(
            spacing: 18,
            runSpacing: 18,
            alignment:
            WrapAlignment.center,
            children:
            values.map((item) {

              return Container(
                width: 90,
                padding:
                const EdgeInsets
                    .symmetric(
                  vertical: 10,
                ),
                decoration:
                BoxDecoration(
                  color: isDark
                      ? const Color(
                      0xFF111827)
                      : const Color(
                      0xFFF1F5F9),
                  borderRadius:
                  BorderRadius
                      .circular(
                      14),
                ),
                child: Column(
                  children: [

                    Text(
                      item[1],
                      textAlign:
                      TextAlign
                          .center,
                      style:
                      GoogleFonts
                          .outfit(
                        fontSize: 13,
                        fontWeight:
                        FontWeight
                            .w700,
                        color:
                        primary,
                      ),
                    ),

                    const SizedBox(
                        height: 3),

                    Text(
                      item[0],
                      style:
                      GoogleFonts
                          .outfit(
                        fontSize: 10,
                        color:
                        secondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(
              height: 20),
        ],
      ),
    );
  }
}