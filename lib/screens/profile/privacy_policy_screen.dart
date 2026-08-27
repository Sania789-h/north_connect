import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main_navigation_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  void _goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardBg = dark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final subColor = dark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Row(
                  children: [
                    _roundBtn(
                      onTap: () => _goBack(context),
                      icon: Icons.arrow_back_ios_new_rounded,
                      dark: dark,
                    ),
                    Expanded(
                      child: Text(
                        'Privacy Policy',
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
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: dark ? Colors.black.withValues(alpha: 0.35) : const Color(0x0E000000),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Policy — North Connect',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Effective Date: 2026',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF067A46),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _sectionTitle('1. Overview', textColor),
                      _paragraph('North Connect ("we", "our") is dedicated to protecting your privacy. This policy outlines how information is collected, stored, and utilized within the application.', subColor),

                      _sectionTitle('2. Information We Collect', textColor),
                      _bullet('Account Information: Name, email address, and phone number registered with Supabase Authentication.', subColor),
                      _bullet('Profile Information: Bio, profile picture, location, and user-provided emergency contacts.', subColor),
                      _bullet('Crowdsourced Data: Network signal reports, road alert submissions, and SOS distress requests.', subColor),
                      _bullet('Device Information: Basic device OS and app version for performance and crash diagnostics.', subColor),

                      _sectionTitle('3. How Information Is Used', textColor),
                      _bullet('To provide core app services: weather updates, road alerts, network reports, and emergency assistance.', subColor),
                      _bullet('To notify your personal emergency contacts when an SOS alert is explicitly triggered by you.', subColor),
                      _bullet('To improve connectivity coverage maps through aggregated, anonymous network reports.', subColor),

                      _sectionTitle('4. Data Security & Storage', textColor),
                      _paragraph('All account authentication and user data are secured using industry-standard encryption, Row-Level Security (RLS) policies, and encrypted HTTPS connections.', subColor),

                      _sectionTitle('5. Data Sharing & Third Parties', textColor),
                      _paragraph('We DO NOT sell or rent your personal data to third parties. Information is shared only when necessary for emergency dispatch or as required by Pakistan law enforcement authorities.', subColor),

                      _sectionTitle('6. Contact Us', textColor),
                      _paragraph('If you have any questions regarding this Privacy Policy, please contact our support team at support@northconnect.pk.', subColor),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF067A46),
        ),
      ),
    );
  }

  Widget _paragraph(String text, Color subColor) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 14,
        height: 1.5,
        color: subColor,
      ),
    );
  }

  Widget _bullet(String text, Color subColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 8, left: 4),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF067A46),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 14,
                height: 1.45,
                color: subColor,
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
