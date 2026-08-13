import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class WeatherService {
  WeatherService._();

  static const double latitude = 35.9208;
  static const double longitude = 74.3083;

  static const String locationName = 'Gilgit, Pakistan';

  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static Future<WeatherData> get current async {
    return fetchWeather();
  }

  static Future<WeatherData> fetchWeather() async {
    final weatherUri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
          '?latitude=$latitude'
          '&longitude=$longitude'
          '&current='
          'temperature_2m,relative_humidity_2m,'
          'apparent_temperature,weather_code,'
          'wind_speed_10m,surface_pressure'
          '&hourly='
          'temperature_2m,relative_humidity_2m,'
          'apparent_temperature,precipitation_probability,'
          'weather_code,wind_speed_10m,uv_index'
          '&daily='
          'weather_code,temperature_2m_max,temperature_2m_min,'
          'sunrise,sunset,precipitation_probability_max,'
          'wind_speed_10m_max,relative_humidity_2m_mean,uv_index_max'
          '&timezone=Asia%2FKarachi'
          '&forecast_days=7',
    );

    final airUri = Uri.parse(
      'https://air-quality-api.open-meteo.com/v1/air-quality'
          '?latitude=$latitude'
          '&longitude=$longitude'
          '&current=pm2_5,pm10,ozone,nitrogen_dioxide'
          '&timezone=Asia%2FKarachi',
    );

    final responses = await Future.wait([
      http.get(weatherUri),
      http.get(airUri),
    ]);

    final weatherResponse = responses[0];
    final airResponse = responses[1];

    if (weatherResponse.statusCode != 200) {
      throw Exception(
        'Weather API error: ${weatherResponse.statusCode}',
      );
    }

    if (airResponse.statusCode != 200) {
      throw Exception(
        'Air quality API error: ${airResponse.statusCode}',
      );
    }

    final weatherJson =
    jsonDecode(weatherResponse.body) as Map<String, dynamic>;

    final airJson =
    jsonDecode(airResponse.body) as Map<String, dynamic>;

    final data = WeatherData.fromJson(
      weatherJson,
      airJson,
    );

    await _saveWeatherToSupabase(data);

    return data;
  }

  static Future<void> _saveWeatherToSupabase(
      WeatherData data,
      ) async {
    final rows = <Map<String, dynamic>>[];

    // =========================================================
    // CURRENT WEATHER
    // =========================================================

    rows.add({
      'location': data.current.locationName,
      'weather_type': data.current.conditionText,
      'temperature':
      '${data.current.temperatureC.round()}°C',
      'description':
      '${data.current.conditionText}, '
          'Humidity ${data.current.humidity}%, '
          'Wind ${data.current.windKmh.toStringAsFixed(0)} km/h',
      'report_type': 'current',
      'forecast_date': _dateOnly(DateTime.now()),
      'forecast_time': DateTime.now().toUtc().toIso8601String(),
    });

    // =========================================================
    // HOURLY FORECAST
    // =========================================================

    for (final item in data.hourly) {
      rows.add({
        'location': locationName,
        'weather_type': item.conditionText,
        'temperature':
        '${item.tempC.round()}°C',
        'description':
        'Humidity ${item.humidity}%, '
            'Wind ${item.windKmh.toStringAsFixed(0)} km/h, '
            'Rain ${item.rainChance}%, '
            'UV ${item.uvIndex}',
        'report_type': 'hourly',
        'forecast_date':
        _dateOnly(item.time),
        'forecast_time':
        item.time.toUtc().toIso8601String(),
      });
    }

    // =========================================================
    // 7 DAY FORECAST
    // =========================================================

    for (final item in data.daily) {
      rows.add({
        'location': locationName,
        'weather_type': item.conditionText,
        'temperature':
        '${item.maxTempC.round()}°C / '
            '${item.minTempC.round()}°C',
        'description':
        'Humidity ${item.humidity}%, '
            'Wind ${item.windKmh.toStringAsFixed(0)} km/h, '
            'Rain ${item.rainChance}%, '
            'UV ${item.uvIndex}',
        'report_type': 'daily',
        'forecast_date':
        _dateOnly(item.date),
        'forecast_time':
        item.date.toUtc().toIso8601String(),
      });
    }

    try {
      // Remove old forecast data.
      await _supabase
          .from('weather_reports')
          .delete()
          .eq('location', locationName)
          .inFilter(
        'report_type',
        ['current', 'hourly', 'daily'],
      );

      // Insert fresh current + hourly + 7-day data.
      if (rows.isNotEmpty) {
        await _supabase
            .from('weather_reports')
            .insert(rows);
      }

      print(
        'Weather saved successfully: '
            '${rows.length} records',
      );
    } catch (e) {
      // Weather should still work if database saving fails.
      print('Weather Supabase save error: $e');
    }
  }

  static String _dateOnly(DateTime date) {
    final d = date.toLocal();

    final year = d.year.toString().padLeft(4, '0');
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

// =============================================================
// WEATHER DATA
// =============================================================

class WeatherData {
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final AirQuality airQuality;

  WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.airQuality,
  });

  factory WeatherData.fromJson(
      Map<String, dynamic> weather,
      Map<String, dynamic> air,
      ) {
    final currentJson =
    weather['current'] as Map<String, dynamic>;

    final hourlyJson =
    weather['hourly'] as Map<String, dynamic>;

    final dailyJson =
    weather['daily'] as Map<String, dynamic>;

    final airCurrent =
        air['current'] as Map<String, dynamic>? ?? {};

    // ---------------------------------------------------------
    // CURRENT
    // ---------------------------------------------------------

    final current = CurrentWeather(
      locationName: WeatherService.locationName,
      temperatureC:
      _doubleValue(currentJson['temperature_2m']),
      apparentTemperatureC:
      _doubleValue(currentJson['apparent_temperature']),
      humidity:
      _intValue(currentJson['relative_humidity_2m']),
      windKmh:
      _doubleValue(currentJson['wind_speed_10m']),
      pressureHpa:
      _doubleValue(currentJson['surface_pressure']),
      condition:
      conditionFromCode(
        _intValue(currentJson['weather_code']),
      ),
    );

    // ---------------------------------------------------------
    // HOURLY
    // ---------------------------------------------------------

    final hourlyTimes =
    List<String>.from(hourlyJson['time'] ?? []);

    final hourlyTemps =
    List<dynamic>.from(
      hourlyJson['temperature_2m'] ?? [],
    );

    final hourlyHumidity =
    List<dynamic>.from(
      hourlyJson['relative_humidity_2m'] ?? [],
    );

    final hourlyRain =
    List<dynamic>.from(
      hourlyJson['precipitation_probability'] ?? [],
    );

    final hourlyCodes =
    List<dynamic>.from(
      hourlyJson['weather_code'] ?? [],
    );

    final hourlyWind =
    List<dynamic>.from(
      hourlyJson['wind_speed_10m'] ?? [],
    );

    final hourlyUv =
    List<dynamic>.from(
      hourlyJson['uv_index'] ?? [],
    );

    final hourly = <HourlyForecast>[];

    final hourlyCount = hourlyTimes.length > 24
        ? 24
        : hourlyTimes.length;

    for (int i = 0; i < hourlyCount; i++) {
      final time =
      DateTime.parse(hourlyTimes[i]);

      hourly.add(
        HourlyForecast(
          time: time,
          timeLabel: _formatHour(time),
          tempC: _doubleAt(hourlyTemps, i),
          humidity: _intAt(hourlyHumidity, i),
          rainChance: _intAt(hourlyRain, i),
          windKmh: _doubleAt(hourlyWind, i),
          uvIndex: _doubleAt(hourlyUv, i),
          condition:
          conditionFromCode(
            _intAt(hourlyCodes, i),
          ),
        ),
      );
    }

    // ---------------------------------------------------------
    // DAILY
    // ---------------------------------------------------------

    final dailyTimes =
    List<String>.from(dailyJson['time'] ?? []);

    final dailyMax =
    List<dynamic>.from(
      dailyJson['temperature_2m_max'] ?? [],
    );

    final dailyMin =
    List<dynamic>.from(
      dailyJson['temperature_2m_min'] ?? [],
    );

    final dailyCodes =
    List<dynamic>.from(
      dailyJson['weather_code'] ?? [],
    );

    final dailySunrise =
    List<dynamic>.from(
      dailyJson['sunrise'] ?? [],
    );

    final dailySunset =
    List<dynamic>.from(
      dailyJson['sunset'] ?? [],
    );

    final dailyRain =
    List<dynamic>.from(
      dailyJson['precipitation_probability_max'] ?? [],
    );

    final dailyWind =
    List<dynamic>.from(
      dailyJson['wind_speed_10m_max'] ?? [],
    );

    final dailyHumidity =
    List<dynamic>.from(
      dailyJson['relative_humidity_2m_mean'] ?? [],
    );

    final dailyUv =
    List<dynamic>.from(
      dailyJson['uv_index_max'] ?? [],
    );

    final daily = <DailyForecast>[];

    for (int i = 0; i < dailyTimes.length; i++) {
      final date =
      DateTime.parse(dailyTimes[i]);

      daily.add(
        DailyForecast(
          date: date,
          dayName: _formatDay(date),
          maxTempC: _doubleAt(dailyMax, i),
          minTempC: _doubleAt(dailyMin, i),
          humidity: _intAt(dailyHumidity, i),
          windKmh: _doubleAt(dailyWind, i),
          rainChance: _intAt(dailyRain, i),
          uvIndex: _doubleAt(dailyUv, i),
          sunrise:
          _formatTime(
            _stringAt(dailySunrise, i),
          ),
          sunset:
          _formatTime(
            _stringAt(dailySunset, i),
          ),
          condition:
          conditionFromCode(
            _intAt(dailyCodes, i),
          ),
        ),
      );
    }

    // ---------------------------------------------------------
    // AIR QUALITY
    // ---------------------------------------------------------

    final pm25 =
    _intValue(airCurrent['pm2_5']);

    final pm10 =
    _intValue(airCurrent['pm10']);

    final ozone =
    _intValue(airCurrent['ozone']);

    final no2 =
    _intValue(airCurrent['nitrogen_dioxide']);

    final aqi =
    pm25 <= 12
        ? 35
        : pm25 <= 35
        ? 75
        : pm25 <= 55
        ? 125
        : 175;

    String level;
    String levelText;

    if (aqi <= 50) {
      level = 'Good';
      levelText =
      'Air quality is good.';
    } else if (aqi <= 100) {
      level = 'Moderate';
      levelText =
      'Air quality is acceptable.';
    } else if (aqi <= 150) {
      level = 'Unhealthy for Sensitive Groups';
      levelText =
      'Sensitive people should reduce prolonged outdoor activity.';
    } else {
      level = 'Unhealthy';
      levelText =
      'Consider reducing prolonged outdoor activity.';
    }

    return WeatherData(
      current: current,
      hourly: hourly,
      daily: daily,
      airQuality: AirQuality(
        aqi: aqi,
        level: level,
        levelText: levelText,
        pm2_5: pm25,
        pm10: pm10,
        o3: ozone,
        no2: no2,
      ),
    );
  }
}

// =============================================================
// CURRENT WEATHER
// =============================================================

class CurrentWeather {
  final String locationName;
  final double temperatureC;
  final double apparentTemperatureC;
  final int humidity;
  final double windKmh;
  final double pressureHpa;
  final WeatherCondition condition;

  CurrentWeather({
    required this.locationName,
    required this.temperatureC,
    required this.apparentTemperatureC,
    required this.humidity,
    required this.windKmh,
    required this.pressureHpa,
    required this.condition,
  });

  String get conditionText =>
      conditionName(condition);
}

// =============================================================
// HOURLY
// =============================================================

class HourlyForecast {
  final DateTime time;
  final String timeLabel;
  final double tempC;
  final int humidity;
  final int rainChance;
  final double windKmh;
  final double uvIndex;
  final WeatherCondition condition;

  HourlyForecast({
    required this.time,
    required this.timeLabel,
    required this.tempC,
    required this.humidity,
    required this.rainChance,
    required this.windKmh,
    required this.uvIndex,
    required this.condition,
  });

  String get conditionText =>
      conditionName(condition);
}

// =============================================================
// DAILY
// =============================================================

class DailyForecast {
  final DateTime date;
  final String dayName;
  final double maxTempC;
  final double minTempC;
  final int humidity;
  final double windKmh;
  final int rainChance;
  final double uvIndex;
  final String sunrise;
  final String sunset;
  final WeatherCondition condition;

  DailyForecast({
    required this.date,
    required this.dayName,
    required this.maxTempC,
    required this.minTempC,
    required this.humidity,
    required this.windKmh,
    required this.rainChance,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.condition,
  });

  String get conditionText =>
      conditionName(condition);
}

// =============================================================
// AIR QUALITY
// =============================================================

class AirQuality {
  final int aqi;
  final String level;
  final String levelText;

  final int pm2_5;
  final int pm10;
  final int o3;
  final int no2;

  AirQuality({
    required this.aqi,
    required this.level,
    required this.levelText,
    required this.pm2_5,
    required this.pm10,
    required this.o3,
    required this.no2,
  });
}

// =============================================================
// WEATHER CONDITION
// =============================================================

enum WeatherCondition {
  sunny,
  partlyCloudy,
  cloudy,
  rainy,
  stormy,
  snowy,
  foggy,
  windy,
}

WeatherCondition conditionFromCode(int code) {
  if (code == 0) {
    return WeatherCondition.sunny;
  }

  if (code == 1 ||
      code == 2) {
    return WeatherCondition.partlyCloudy;
  }

  if (code == 3) {
    return WeatherCondition.cloudy;
  }

  if (code == 45 ||
      code == 48) {
    return WeatherCondition.foggy;
  }

  if (code == 51 ||
      code == 53 ||
      code == 55 ||
      code == 56 ||
      code == 57 ||
      code == 61 ||
      code == 63 ||
      code == 65 ||
      code == 66 ||
      code == 67 ||
      code == 80 ||
      code == 81 ||
      code == 82) {
    return WeatherCondition.rainy;
  }

  if (code == 71 ||
      code == 73 ||
      code == 75 ||
      code == 77 ||
      code == 85 ||
      code == 86) {
    return WeatherCondition.snowy;
  }

  if (code == 95 ||
      code == 96 ||
      code == 99) {
    return WeatherCondition.stormy;
  }

  return WeatherCondition.windy;
}

String conditionName(WeatherCondition condition) {
  switch (condition) {
    case WeatherCondition.sunny:
      return 'Sunny';

    case WeatherCondition.partlyCloudy:
      return 'Partly Cloudy';

    case WeatherCondition.cloudy:
      return 'Cloudy';

    case WeatherCondition.rainy:
      return 'Rainy';

    case WeatherCondition.stormy:
      return 'Stormy';

    case WeatherCondition.snowy:
      return 'Snowy';

    case WeatherCondition.foggy:
      return 'Foggy';

    case WeatherCondition.windy:
      return 'Windy';
  }
}

// =============================================================
// HELPERS
// =============================================================

double _doubleValue(dynamic value) {
  if (value == null) return 0;

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString()) ?? 0;
}

int _intValue(dynamic value) {
  if (value == null) return 0;

  if (value is num) {
    return value.round();
  }

  return int.tryParse(value.toString()) ?? 0;
}

double _doubleAt(
    List<dynamic> list,
    int index,
    ) {
  if (index >= list.length) return 0;
  return _doubleValue(list[index]);
}

int _intAt(
    List<dynamic> list,
    int index,
    ) {
  if (index >= list.length) return 0;
  return _intValue(list[index]);
}

String _stringAt(
    List<dynamic> list,
    int index,
    ) {
  if (index >= list.length) return '';
  return list[index]?.toString() ?? '';
}

String _formatHour(DateTime date) {
  final hour = date.hour;

  if (hour == 0) return '12 AM';
  if (hour == 12) return '12 PM';

  if (hour > 12) {
    return '${hour - 12} PM';
  }

  return '$hour AM';
}

String _formatDay(DateTime date) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  return days[date.weekday - 1];
}

String _formatTime(String value) {
  if (value.isEmpty) return '--';

  try {
    final date = DateTime.parse(value);

    final hour = date.hour;
    final minute =
    date.minute.toString().padLeft(2, '0');

    if (hour == 0) {
      return '12:$minute AM';
    }

    if (hour == 12) {
      return '12:$minute PM';
    }

    if (hour > 12) {
      return '${hour - 12}:$minute PM';
    }

    return '$hour:$minute AM';
  } catch (_) {
    return value;
  }
}