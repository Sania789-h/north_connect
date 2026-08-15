import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_images.dart';
import '../main_navigation_screen.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                  ),
                  Expanded(
                    child: Text(
                      'About App',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
              const SizedBox(height: 50),
              // ───────── APP LOGO FROM ASSETS ─────────
              ClipOval(
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF067A46),
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      AppImages.logo,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.app_shortcut_rounded,
                        size: 80,
                        color: Color(0xFF067A46),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // ───────── TITLE: GB (navy) + CONNECT (green) ─────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'GB ',
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: const Color(0xFF0F3460),
                    ),
                  ),
                  Text(
                    'CONNECT',
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: const Color(0xFF067A46),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              // ───────── VERSION ─────────
              Text(
                'Version 1.0.0',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 40),
              // ───────── DESCRIPTION (2 lines, centered) ─────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'GB Connect is your all-in-one\nsafety companion app for Gilgit Baltistan. Stay updated, stay safe.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundBtn({
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 8,
                offset: Offset(0, 2)),
          ],
        ),
        child: Icon(icon,
            size: 18, color: const Color(0xFF1E293B)),
      ),
    );
  }
}
