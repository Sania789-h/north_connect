import 'dart:math';

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
  final double temperatureC;
  final double feelsLikeC;
  final WeatherCondition condition;
  final String conditionText;
  final int humidity;
  final double windKmh;
  final int pressureHpa;
  final int uvIndex;
  final double visibilityKm;
  final String locationName;
  final String region;

  const CurrentWeather({
    required this.temperatureC,
    required this.feelsLikeC,
    required this.condition,
    required this.conditionText,
    required this.humidity,
    required this.windKmh,
    required this.pressureHpa,
    required this.uvIndex,
    required this.visibilityKm,
    required this.locationName,
    required this.region,
  });
}

class HourlyForecast {
  final String timeLabel;
  final DateTime time;
  final double tempC;
  final WeatherCondition condition;
  final int humidity;
  final double windKmh;
  final int uvIndex;
  final int rainChance;

  const HourlyForecast({
    required this.timeLabel,
    required this.time,
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
  final DateTime date;
  final double maxTempC;
  final double minTempC;
  final WeatherCondition condition;
  final int rainChance;
  final int humidity;
  final double windKmh;
  final int uvIndex;
  final String sunrise;
  final String sunset;

  const DailyForecast({
    required this.dayName,
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.condition,
    required this.rainChance,
    required this.humidity,
    required this.windKmh,
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
  final DateTime updatedAt;

  WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.airQuality,
    required this.updatedAt,
  });
}

class WeatherService {
  static const _locations = [
    'Gilgit',
    'Skardu',
    'Hunza',
    'Naltar',
    'Astore',
    'Kaghan',
  ];

  static WeatherCondition conditionFromString(String s) {
    switch (s.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return WeatherCondition.sunny;
      case 'partly cloudy':
        return WeatherCondition.partlyCloudy;
      case 'cloudy':
      case 'overcast':
        return WeatherCondition.cloudy;
      case 'rain':
      case 'rainy':
      case 'drizzle':
        return WeatherCondition.rainy;
      case 'thunder':
      case 'storm':
        return WeatherCondition.stormy;
      case 'snow':
      case 'snowy':
        return WeatherCondition.snowy;
      case 'fog':
      case 'mist':
      case 'haze':
        return WeatherCondition.foggy;
      case 'windy':
        return WeatherCondition.windy;
      default:
        return WeatherCondition.partlyCloudy;
    }
  }

  static int _elevFactor(String location) {
    final l = location.toLowerCase();
    if (l.contains('skardu')) return 2240;
    if (l.contains('hunza')) return 2450;
    if (l.contains('naltar')) return 3050;
    if (l.contains('astore')) return 2550;
    if (l.contains('kaghan')) return 2400;
    return 1480;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static Future<WeatherData> getWeatherForLocation(String location) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    final baseHour = now.hour;

    final rnd = Random(location.hashCode + now.day);
    final region =
        location.contains(',') ? location.split(',').first.trim() : location;

    final elev = _elevFactor(location);
    final tempBase = 32.5 - (elev / 200);

    final tempRnd = (rnd.nextDouble() * 3) - 1.5;
    final closeToNoon = (baseHour - 13).abs() < 4;
    final hourAdj = closeToNoon ? 2 : -2;
    final currentTemp =
        double.parse((tempBase + tempRnd + hourAdj).toStringAsFixed(1));
    final feels = double.parse(
        (tempBase + tempRnd + hourAdj + (rnd.nextDouble() - 0.8))
            .toStringAsFixed(1));

    final humidity = 30 + rnd.nextInt(35);
    final wind = double.parse((6 + rnd.nextDouble() * 14).toStringAsFixed(0));
    final pressure = 1008 + rnd.nextInt(14);
    final uvMax = elev > 2400 ? 7 : 6;
    final distFromNoon = (baseHour - 12).abs();
    final uv = (uvMax - (distFromNoon ~/ 2)).clamp(0, 11);

    final condOptions = elev > 2800
        ? ['Partly Cloudy', 'Sunny', 'Snowy', 'Cloudy']
        : ['Partly Cloudy', 'Sunny', 'Cloudy', 'Rainy'];
    final condText = condOptions[rnd.nextInt(condOptions.length)];

    final current = CurrentWeather(
      temperatureC: currentTemp,
      feelsLikeC: feels,
      condition: conditionFromString(condText),
      conditionText: condText,
      humidity: humidity,
      windKmh: wind,
      pressureHpa: pressure,
      uvIndex: uv,
      visibilityKm: double.parse((8 + rnd.nextDouble() * 12).toStringAsFixed(1)),
      locationName: location,
      region: region,
    );

    final hourly = List<HourlyForecast>.generate(12, (i) {
      final hour24 = (baseHour + i) % 24;
      final String timeLabel;
      if (i == 0) {
        timeLabel = 'Now';
      } else if (hour24 == 0) {
        timeLabel = '12 AM';
      } else if (hour24 < 12) {
        timeLabel = '${hour24} AM';
      } else if (hour24 == 12) {
        timeLabel = '12 PM';
      } else {
        timeLabel = '${hour24 - 12} PM';
      }

      final double adj;
      if (hour24 >= 11 && hour24 <= 15) {
        adj = 2.5;
      } else if (hour24 >= 8 && hour24 <= 18) {
        adj = 1.0;
      } else if (hour24 >= 5 && hour24 <= 20) {
        adj = -0.5;
      } else {
        adj = -3.0;
      }

      final hTemp =
          double.parse((tempBase + adj + rnd.nextDouble() * 0.8).toStringAsFixed(1));
      final hCond = (hour24 >= 6 && hour24 <= 18)
          ? (i % 3 == 0 ? WeatherCondition.sunny : WeatherCondition.partlyCloudy)
          : WeatherCondition.cloudy;
      final hHumidity = (55 - adj * 2 + rnd.nextInt(12)).round().clamp(20, 95);
      final hWind =
          double.parse((5 + rnd.nextDouble() * 13).toStringAsFixed(0));
      final int hUv;
      if (hour24 >= 10 && hour24 <= 16) {
        hUv = (uvMax - (hour24 - 13).abs()).clamp(0, 11);
      } else {
        hUv = (uvMax - 3 - (hour24 - 12).abs()).clamp(0, 11);
      }
      final hRain = (i % 5 == 0) ? 10 + rnd.nextInt(20) : rnd.nextInt(12);

      return HourlyForecast(
        timeLabel: timeLabel,
        time: now.add(Duration(hours: i)),
        tempC: hTemp,
        condition: hCond,
        humidity: hHumidity,
        windKmh: hWind,
        uvIndex: hUv,
        rainChance: hRain,
      );
    });

    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final daily = List<DailyForecast>.generate(5, (i) {
      final dayDate = now.add(Duration(days: i));
      final idx = dayDate.weekday - 1;
      final dayName = i == 0 ? 'Today' : dayNames[idx % 7];
      final maxT =
          double.parse((tempBase + 2 + rnd.nextDouble() * 1.6).toStringAsFixed(1));
      final minT =
          double.parse((tempBase - 8 + rnd.nextDouble() * 2).toStringAsFixed(1));
      final dCondIdx = (i + rnd.nextInt(3)) % 4;
      final dCond = WeatherCondition.values[dCondIdx];
      final sunriseMin = 25 + rnd.nextInt(15);
      final sunsetMin = 10 + rnd.nextInt(30);
      return DailyForecast(
        dayName: dayName,
        date: dayDate,
        maxTempC: maxT,
        minTempC: minT,
        condition: dCond,
        rainChance: rnd.nextInt(35),
        humidity: 35 + rnd.nextInt(30),
        windKmh: double.parse((7 + rnd.nextDouble() * 12).toStringAsFixed(0)),
        uvIndex: (uvMax - rnd.nextInt(2)).clamp(0, 11),
        sunrise: '05:${_two(sunriseMin)}',
        sunset: '19:${_two(sunsetMin)}',
      );
    });

    final aqiBase = elev > 2200 ? 22 + rnd.nextInt(18) : 30 + rnd.nextInt(22);
    final String lvl;
    final String txt;
    if (aqiBase <= 50) {
      lvl = 'Good';
      txt = 'Air quality is satisfactory';
    } else if (aqiBase <= 100) {
      lvl = 'Moderate';
      txt = 'Air quality is acceptable';
    } else if (aqiBase <= 150) {
      lvl = 'Unhealthy for Sensitive';
      txt = 'Sensitive groups may experience effects';
    } else {
      lvl = 'Unhealthy';
      txt = 'Everyone may experience health effects';
    }
    final airQuality = AirQuality(
      aqi: aqiBase,
      level: lvl,
      levelText: txt,
      pm2_5: (aqiBase * 0.4).round(),
      pm10: (aqiBase * 0.8).round(),
      o3: 20 + rnd.nextInt(30),
      no2: 4 + rnd.nextInt(10),
    );

    return WeatherData(
      current: current,
      hourly: hourly,
      daily: daily,
      airQuality: airQuality,
      updatedAt: now,
    );
  }

  static Future<WeatherData> get current async =>
      getWeatherForLocation('Gilgit, Pakistan');

  static List<String> get suggestedLocations =>
      _locations.map((l) => '$l, Pakistan').toList(growable: false);
}
