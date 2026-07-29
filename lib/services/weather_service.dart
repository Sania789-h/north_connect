import 'package:flutter/foundation.dart';

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

class CurrentWeather {
  final String locationName;
  final double temperatureC;
  final String conditionText;
  final WeatherCondition condition;
  final int humidity;
  final double windKmh;
  final int pressureHpa;

  const CurrentWeather({
    required this.locationName,
    required this.temperatureC,
    required this.conditionText,
    required this.condition,
    required this.humidity,
    required this.windKmh,
    required this.pressureHpa,
  });
}

class HourlyForecast {
  final String timeLabel;
  final double tempC;
  final WeatherCondition condition;
  final int humidity;
  final double windKmh;
  final int uvIndex;
  final int rainChance;

  const HourlyForecast({
    required this.timeLabel,
    required this.tempC,
    required this.condition,
    required this.humidity,
    required this.windKmh,
    required this.uvIndex,
    required this.rainChance,
  });
}

class DailyForecast {
  final String dayName;
  final double maxTempC;
  final double minTempC;
  final WeatherCondition condition;
  final int humidity;
  final double windKmh;
  final int rainChance;
  final int uvIndex;
  final String sunrise;
  final String sunset;

  const DailyForecast({
    required this.dayName,
    required this.maxTempC,
    required this.minTempC,
    required this.condition,
    required this.humidity,
    required this.windKmh,
    required this.rainChance,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
  });
}

class AirQuality {
  final int aqi;
  final String level;
  final String levelText;
  final int pm2_5;
  final int pm10;
  final int o3;
  final int no2;

  const AirQuality({
    required this.aqi,
    required this.level,
    required this.levelText,
    required this.pm2_5,
    required this.pm10,
    required this.o3,
    required this.no2,
  });
}

class WeatherData {
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final AirQuality airQuality;

  const WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.airQuality,
  });
}

class WeatherService {
  WeatherService._();

  static Future<WeatherData> get current async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return _mockGilgitWeather();
    } catch (e) {
      debugPrint('WeatherService error: $e');
      rethrow;
    }
  }

  static WeatherData _mockGilgitWeather() {
    final now = DateTime.now();
    final hour24 = now.hour;

    final hours = <HourlyForecast>[];
    for (int i = 0; i < 12; i++) {
      final h = (hour24 + i) % 24;
      final isDay = h >= 6 && h <= 18;
      final double baseTemp = isDay ? 19 : 11;
      final variance = (h - 13).abs() * -0.4;
      final temp = baseTemp + variance;

      WeatherCondition cond;
      if (i == 0) {
        cond = WeatherCondition.partlyCloudy;
      } else if (i == 2 || i == 3) {
        cond = WeatherCondition.cloudy;
      } else if (i == 5 || i == 6) {
        cond = WeatherCondition.rainy;
      } else if (!isDay) {
        cond = WeatherCondition.cloudy;
      } else if (i < 2) {
        cond = WeatherCondition.sunny;
      } else {
        cond = WeatherCondition.partlyCloudy;
      }

      final label = i == 0
          ? 'Now'
          : '${(h % 12 == 0 ? 12 : h % 12)} ${h < 12 ? 'AM' : 'PM'}';

      hours.add(HourlyForecast(
        timeLabel: label,
        tempC: double.parse(temp.toStringAsFixed(1)),
        condition: cond,
        humidity: 35 + (i * 3) % 30,
        windKmh: 8 + (i * 1.5) % 14,
        uvIndex: isDay ? (12 - (h - 13).abs()).clamp(0, 10) : 0,
        rainChance: (cond == WeatherCondition.rainy)
            ? 75
            : (cond == WeatherCondition.cloudy ? 28 : 8),
      ));
    }

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIdx = (now.weekday - 1) % 7;

    const dailyConditions = [
      WeatherCondition.sunny,
      WeatherCondition.partlyCloudy,
      WeatherCondition.cloudy,
      WeatherCondition.rainy,
      WeatherCondition.windy,
      WeatherCondition.partlyCloudy,
      WeatherCondition.foggy,
    ];
    const dailyMax = [22.0, 20.5, 18.0, 15.0, 19.5, 21.0, 17.0];
    const dailyMin = [9.0, 10.0, 8.0, 6.0, 7.5, 10.0, 5.0];
    const dailyHum = [30, 38, 55, 78, 42, 34, 62];
    const dailyWind = [6.0, 9.0, 12.0, 16.0, 22.0, 8.0, 4.0];
    const dailyRain = [5, 18, 35, 72, 20, 12, 40];
    const dailyUv = [8, 6, 4, 2, 5, 7, 3];
    const sunrises = ['05:48', '05:49', '05:50', '05:51', '05:52', '05:53', '05:54'];
    const sunsets = ['19:12', '19:11', '19:10', '19:09', '19:08', '19:07', '19:06'];

    final days = <DailyForecast>[];
    for (int i = 0; i < 7; i++) {
      final idx = (todayIdx + i) % 7;
      final label = i == 0 ? 'Today' : dayNames[idx];
      days.add(DailyForecast(
        dayName: label,
        maxTempC: dailyMax[i],
        minTempC: dailyMin[i],
        condition: dailyConditions[i],
        humidity: dailyHum[i],
        windKmh: dailyWind[i],
        rainChance: dailyRain[i],
        uvIndex: dailyUv[i],
        sunrise: sunrises[i],
        sunset: sunsets[i],
      ));
    }

    return WeatherData(
      current: const CurrentWeather(
        locationName: 'Gilgit, Pakistan',
        temperatureC: 18.0,
        conditionText: 'Partly Cloudy',
        condition: WeatherCondition.partlyCloudy,
        humidity: 37,
        windKmh: 12.0,
        pressureHpa: 1012,
      ),
      hourly: hours,
      daily: days,
      airQuality: const AirQuality(
        aqi: 42,
        level: 'Good',
        levelText: 'Air quality is satisfactory and poses little or no health risk. Enjoy outdoor activities safely.',
        pm2_5: 18,
        pm10: 34,
        o3: 28,
        no2: 14,
      ),
    );
  }
}
