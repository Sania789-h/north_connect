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
    final hours = <HourlyForecast>[
      const HourlyForecast(
        timeLabel: 'Now',
        tempC: 18.0,
        condition: WeatherCondition.partlyCloudy,
        humidity: 37,
        windKmh: 12.0,
        uvIndex: 4,
        rainChance: 10,
      ),
      const HourlyForecast(
        timeLabel: '11 AM',
        tempC: 19.0,
        condition: WeatherCondition.sunny,
        humidity: 36,
        windKmh: 12.0,
        uvIndex: 5,
        rainChance: 5,
      ),
      const HourlyForecast(
        timeLabel: '12 PM',
        tempC: 20.0,
        condition: WeatherCondition.partlyCloudy,
        humidity: 35,
        windKmh: 13.0,
        uvIndex: 6,
        rainChance: 10,
      ),
      const HourlyForecast(
        timeLabel: '1 PM',
        tempC: 21.0,
        condition: WeatherCondition.sunny,
        humidity: 34,
        windKmh: 14.0,
        uvIndex: 7,
        rainChance: 5,
      ),
      const HourlyForecast(
        timeLabel: '2 PM',
        tempC: 22.0,
        condition: WeatherCondition.sunny,
        humidity: 33,
        windKmh: 13.0,
        uvIndex: 6,
        rainChance: 5,
      ),
      const HourlyForecast(
        timeLabel: '3 PM',
        tempC: 22.0,
        condition: WeatherCondition.partlyCloudy,
        humidity: 35,
        windKmh: 12.0,
        uvIndex: 5,
        rainChance: 10,
      ),
    ];

    final days = <DailyForecast>[
      const DailyForecast(
        dayName: 'Thursday',
        maxTempC: 23.0,
        minTempC: 12.0,
        condition: WeatherCondition.partlyCloudy,
        humidity: 38,
        windKmh: 11.0,
        rainChance: 15,
        uvIndex: 6,
        sunrise: '05:48',
        sunset: '19:12',
      ),
      const DailyForecast(
        dayName: 'Friday',
        maxTempC: 24.0,
        minTempC: 13.0,
        condition: WeatherCondition.partlyCloudy,
        humidity: 36,
        windKmh: 10.0,
        rainChance: 10,
        uvIndex: 7,
        sunrise: '05:49',
        sunset: '19:11',
      ),
      const DailyForecast(
        dayName: 'Saturday',
        maxTempC: 25.0,
        minTempC: 14.0,
        condition: WeatherCondition.partlyCloudy,
        humidity: 34,
        windKmh: 12.0,
        rainChance: 5,
        uvIndex: 7,
        sunrise: '05:50',
        sunset: '19:10',
      ),
      const DailyForecast(
        dayName: 'Sunday',
        maxTempC: 22.0,
        minTempC: 11.0,
        condition: WeatherCondition.sunny,
        humidity: 32,
        windKmh: 14.0,
        rainChance: 0,
        uvIndex: 8,
        sunrise: '05:51',
        sunset: '19:09',
      ),
      const DailyForecast(
        dayName: 'Monday',
        maxTempC: 21.0,
        minTempC: 10.0,
        condition: WeatherCondition.partlyCloudy,
        humidity: 40,
        windKmh: 13.0,
        rainChance: 20,
        uvIndex: 5,
        sunrise: '05:52',
        sunset: '19:08',
      ),
    ];

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
        aqi: 32,
        level: 'Good',
        levelText: 'Air quality is satisfactory and poses little or no health risk. Enjoy outdoor activities safely.',
        pm2_5: 14,
        pm10: 28,
        o3: 22,
        no2: 10,
      ),
    );
  }
}
