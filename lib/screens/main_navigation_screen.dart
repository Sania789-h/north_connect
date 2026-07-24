import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home/home_screen.dart';
import 'weather/weather_screen.dart';
import 'alerts/alerts_screen.dart';
import 'network/network_screen.dart';
import 'profile/profile_screen.dart';

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
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelect(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onNavigateTab: (index) => _onTabSelect(index),
      ),
      const WeatherScreen(),
      const AlertsScreen(),
      const NetworkScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
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
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF067A46),
              unselectedItemColor: const Color(0xFF94A3B8),
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
                BottomNavigationBarItem(
                  icon: Badge(
                    label: const Text('3', style: TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: const Color(0xFFEF4444),
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                  activeIcon: Badge(
                    label: const Text('3', style: TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: const Color(0xFFEF4444),
                    child: const Icon(Icons.notifications_rounded),
                  ),
                  label: "Alerts",
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.cell_tower_rounded),
                  label: "Network",
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
