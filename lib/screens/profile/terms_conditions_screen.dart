import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main_navigation_screen.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
                        'Terms & Conditions',
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
                        'Terms & Conditions — North Connect',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Last Updated: 2026',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF067A46),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _sectionTitle('1. Acceptance of Terms', textColor),
                      _paragraph('By downloading, accessing, or using the North Connect mobile application, you agree to comply with and be bound by these Terms and Conditions.', subColor),

                      _sectionTitle('2. Service Purpose & Scope', textColor),
                      _paragraph('North Connect provides weather forecasts, crowdsourced network signal strength, road alerts, and emergency SOS features tailored for the Gilgit-Baltistan region. All information is provided on a best-effort basis for informational and safety assistance.', subColor),

                      _sectionTitle('3. Acceptable Use Policy', textColor),
                      _bullet('Users must submit authentic and truthful road alerts and network reports.', subColor),
                      _bullet('Hoax, false, or malicious emergency SOS alerts are strictly prohibited and may result in account termination.', subColor),
                      _bullet('Do not attempt to disrupt services, probe vulnerabilities, or misuse API endpoints.', subColor),

                      _sectionTitle('4. Disclaimers & Travel Safety Notice', textColor),
                      _paragraph('Weather predictions and road conditions in high-altitude mountain areas can change rapidly. Information provided by North Connect is indicative and should be combined with official government warnings and local advisory.', subColor),

                      _sectionTitle('5. Limitation of Liability', textColor),
                      _paragraph('To the maximum extent permitted by applicable laws of Pakistan, North Connect and its developers shall not be liable for any indirect, incidental, or consequential damages resulting from weather conditions, road delays, or network outages.', subColor),

                      _sectionTitle('6. Account Management', textColor),
                      _paragraph('You may update your profile or request account deletion at any time through the app settings or by emailing support@northconnect.pk.', subColor),

                      _sectionTitle('7. Governing Law', textColor),
                      _paragraph('These terms shall be governed by and construed in accordance with the laws of the Islamic Republic of Pakistan.', subColor),
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
