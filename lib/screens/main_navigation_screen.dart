import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home/home_screen.dart';
import 'weather/weather_screen.dart';
import 'alerts/alerts_screen.dart';
import 'network/network_screen.dart';


class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.initialIndex >= 0 && widget.initialIndex < 4)
        ? widget.initialIndex
        : 0;
  }

  void _onTabSelect(int index) {
    if (index >= 0 && index < 4) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final navBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final navShadow = isDark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.06);
    final unselectedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);
    final selectedColor = isDark ? const Color(0xFF22C55E) : const Color(0xFF067A46);

    final List<Widget> screens = [
      HomeScreen(
        onNavigateTab: (index) => _onTabSelect(index),
      ),
      const WeatherScreen(),
      const AlertsScreen(),
      const NetworkScreen(),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [
            BoxShadow(
              color: navShadow,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabSelect,
              backgroundColor: navBg,
              selectedItemColor: selectedColor,
              unselectedItemColor: unselectedColor,
              selectedLabelStyle: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: "Home",
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.cloud_outlined),
                  activeIcon: Icon(Icons.cloud_rounded),
                  label: "Weather",
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_none_rounded),
                  activeIcon: Icon(Icons.notifications_rounded),
                  label: "Alerts",
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.cell_tower_rounded),
                  label: "Network",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
