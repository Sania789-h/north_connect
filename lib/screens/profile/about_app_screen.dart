import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_images.dart';
import '../main_navigation_screen.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardBg = dark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final subColor = dark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  _roundBtn(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainNavigationScreen(),
                          ),
                        );
                      }
                    },
                    icon: Icons.arrow_back_ios_new_rounded,
                    dark: dark,
                  ),
                  Expanded(
                    child: Text(
                      'About North Connect',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
              const SizedBox(height: 30),

              // ───────── APP LOGO FROM ASSETS ─────────
              ClipOval(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF067A46),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: dark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      AppImages.logo,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.app_shortcut_rounded,
                        size: 70,
                        color: Color(0xFF067A46),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ───────── TITLE ─────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NORTH ',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: dark ? const Color(0xFF60A5FA) : const Color(0xFF0F3460),
                    ),
                  ),
                  Text(
                    'CONNECT',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: const Color(0xFF067A46),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Text(
                'Version 1.0.0+1',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF067A46),
                ),
              ),
              const SizedBox(height: 24),

              // ───────── EXACT REQUIRED DESCRIPTION ─────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: dark ? Colors.black.withValues(alpha: 0.3) : const Color(0x0E000000),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'North Connect is a smart connectivity and safety application designed for the people of Gilgit-Baltistan. It provides weather information, road alerts, network reports, emergency assistance and important safety updates in one place.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: subColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ───────── KEY FEATURES ─────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: dark ? Colors.black.withValues(alpha: 0.3) : const Color(0x0E000000),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Key Features',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _featureRow(Icons.cloud_queue_rounded, 'Weather Forecasts & Hourly Data', subColor, textColor),
                    _featureRow(Icons.add_road_rounded, 'Real-time Road & Route Alerts', subColor, textColor),
                    _featureRow(Icons.cell_tower_rounded, 'Crowdsourced Network Coverage Reports', subColor, textColor),
                    _featureRow(Icons.sos_rounded, 'One-Tap Emergency Assistance (SOS)', subColor, textColor),
                    _featureRow(Icons.location_on_outlined, 'Location-Based Services & Offline Caching', subColor, textColor),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ───────── DEVELOPER INFO ─────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: dark ? Colors.black.withValues(alpha: 0.3) : const Color(0x0E000000),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Developer Information',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Developed for Gilgit-Baltistan\nSATA Technologies',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: subColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '© 2026 North Connect. All rights reserved.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text, Color subColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF067A46).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF067A46)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundBtn({
    required VoidCallback onTap,
    required IconData icon,
    required bool dark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: dark ? Colors.black.withValues(alpha: 0.3) : const Color(0x0F000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: dark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
    );
  }
}
