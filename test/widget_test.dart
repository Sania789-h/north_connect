import 'package:flutter_test/flutter_test.dart';
import 'package:north_connect/core/constants/strings.dart';

void main() {
  test('App title and branding constants check', () {
    expect(AppStrings.appName, equals('North Connect'));
    expect(AppStrings.welcome, equals('Welcome to North Connect'));
  });
}