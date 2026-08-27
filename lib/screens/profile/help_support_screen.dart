import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main_navigation_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final GlobalKey<FormState> _contactFormKey = GlobalKey();
  final GlobalKey<FormState> _reportFormKey = GlobalKey();

  final _contactNameCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();
  final _contactMsgCtrl = TextEditingController();

  final _reportTitleCtrl = TextEditingController();
  final _reportDescCtrl = TextEditingController();

  @override
  void dispose() {
    _contactNameCtrl.dispose();
    _contactEmailCtrl.dispose();
    _contactMsgCtrl.dispose();
    _reportTitleCtrl.dispose();
    _reportDescCtrl.dispose();
    super.dispose();
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  Future<void> _launchEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      _toast('Could not open email app. Please write to us at $to');
    }
  }

  void _toast(String msg, [Color color = const Color(0xFF067A46)]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ───────── SUB-SCREENS ─────────

  void _openFAQs() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _FAQsScreen()),
    );
  }

  void _openContactUs() {
    HapticFeedback.selectionClick();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = dark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF1E293B);
    final subColor = dark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _contactFormKey,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Contact Us',
                      style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                  const SizedBox(height: 4),
                  Text('Our team usually responds within 24 hours.',
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: subColor)),
                  const SizedBox(height: 16),
                  _field(
                    ctrl: _contactNameCtrl,
                    label: 'Your Name',
                    hint: 'e.g. Ali Raza',
                    dark: dark,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Please enter your name'
                            : null,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    ctrl: _contactEmailCtrl,
                    label: 'Your Email',
                    hint: 'you@email.com',
                    keyboard: TextInputType.emailAddress,
                    dark: dark,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Email is required';
                      if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                          .hasMatch(s)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _field(
                    ctrl: _contactMsgCtrl,
                    label: 'Your Message',
                    hint: 'How can we help?',
                    maxLines: 4,
                    dark: dark,
                    validator: (v) =>
                        (v == null || v.trim().length < 10)
                            ? 'Message should be at least 10 chars'
                            : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_contactFormKey.currentState!.validate()) {
                          return;
                        }
                        _launchEmail(
                          to: 'support@northconnect.pk',
                          subject:
                              'Contact Request from ${_contactNameCtrl.text.trim()}',
                          body:
                              'Name: ${_contactNameCtrl.text.trim()}\nEmail: ${_contactEmailCtrl.text.trim()}\n\n${_contactMsgCtrl.text.trim()}',
                        ).then((_) {
                          if (mounted) {
                            Navigator.pop(context);
                            _toast('Thanks! Your message has been prepared.');
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF067A46),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text('Send Message',
                          style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openReportIssue() {
    HapticFeedback.selectionClick();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = dark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF1E293B);
    final subColor = dark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _reportFormKey,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Report an Issue',
                      style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                  const SizedBox(height: 4),
                  Text('Tell us what went wrong and we\'ll fix it fast.',
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: subColor)),
                  const SizedBox(height: 16),
                  _field(
                    ctrl: _reportTitleCtrl,
                    label: 'Issue Title',
                    hint: 'e.g. Weather forecast not loading',
                    dark: dark,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Please enter a short title'
                            : null,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    ctrl: _reportDescCtrl,
                    label: 'Description',
                    hint: 'Steps to reproduce, expected & actual results...',
                    maxLines: 5,
                    dark: dark,
                    validator: (v) =>
                        (v == null || v.trim().length < 15)
                            ? 'Please describe at least 15 characters'
                            : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_reportFormKey.currentState!.validate()) {
                          return;
                        }
                        _launchEmail(
                          to: 'bugs@northconnect.pk',
                          subject:
                              '[BUG REPORT] ${_reportTitleCtrl.text.trim()}',
                          body:
                              'Title: ${_reportTitleCtrl.text.trim()}\n\n${_reportDescCtrl.text.trim()}',
                        ).then((_) {
                          if (mounted) {
                            Navigator.pop(context);
                            _toast('Issue submitted — thank you!');
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text('Submit Report',
                          style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openPrivacyPolicy() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  void _openTermsConditions() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardBg = dark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final subColor = dark ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                child: Row(
                  children: [
                    _roundBtn(
                      onTap: _goBack,
                      icon: Icons.arrow_back_ios_new_rounded,
                      dark: dark,
                    ),
                    Expanded(
                      child: Text(
                        'Help & Support',
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        _tile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & FAQs',
                          onTap: _openFAQs,
                          dark: dark,
                          textColor: textColor,
                        ),
                        _Divider(dark: dark),
                        _tile(
                          icon: Icons.mark_email_unread_outlined,
                          title: 'Contact Us',
                          onTap: _openContactUs,
                          dark: dark,
                          textColor: textColor,
                        ),
                        _Divider(dark: dark),
                        _tile(
                          icon: Icons.report_gmailerrorred_rounded,
                          title: 'Report an Issue',
                          onTap: _openReportIssue,
                          dark: dark,
                          textColor: const Color(0xFFEF4444),
                        ),
                        _Divider(dark: dark),
                        _tile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: _openPrivacyPolicy,
                          dark: dark,
                          textColor: textColor,
                        ),
                        _Divider(dark: dark),
                        _tile(
                          icon: Icons.description_outlined,
                          title: 'Terms & Conditions',
                          onTap: _openTermsConditions,
                          dark: dark,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                child: Text(
                  'Need urgent help? Call Rescue 1122 for roadside emergencies in Pakistan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: subColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
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
        child: Icon(icon, size: 18, color: dark ? Colors.white : const Color(0xFF1E293B)),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool dark,
    Color? textColor,
  }) {
    final itemColor = textColor ?? (dark ? Colors.white : const Color(0xFF1E293B));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFF067A46).withValues(alpha: 0.05),
        highlightColor: const Color(0xFF067A46).withValues(alpha: 0.025),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 28, color: itemColor),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: itemColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right_rounded,
                  size: 22, color: dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required bool dark,
    TextInputType? keyboard,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final labelColor = dark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final fieldBg = dark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final fieldText = dark ? Colors.white : const Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label,
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: labelColor),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          minLines: 1,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: fieldText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            filled: true,
            fillColor: fieldBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.2),
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(0xFF067A46), width: 1.6),
              borderRadius: BorderRadius.circular(14),
            ),
            errorBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(0xFFEF4444), width: 1.2),
              borderRadius: BorderRadius.circular(14),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(0xFFEF4444), width: 1.6),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool dark;
  const _Divider({required this.dark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
    );
  }
}

// ═══════════════════════════════════════════════
// FAQs Screen
// ═══════════════════════════════════════════════
class _FAQsScreen extends StatefulWidget {
  const _FAQsScreen();

  @override
  State<_FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<_FAQsScreen> {
  final List<_FAQ> _faqs = [
    _FAQ(
      q: 'How to check weather?',
      a:
          'Open the Weather tab from the bottom navigation bar to view real-time temperature, hourly forecasts, wind speeds, and 7-day weather predictions for Gilgit, Skardu, Hunza, Nagar, Astore, Ghizer, and Khaplu.',
    ),
    _FAQ(
      q: 'How to view road alerts?',
      a:
          'Go to the Alerts tab or Home screen to view active road closures, landsliding notices, Karakoram Highway (KKH) conditions, Babusar Pass status, and snow blockages reported by local traffic police and community members.',
    ),
    _FAQ(
      q: 'How to submit a network report?',
      a:
          'Open the Network tab, tap the "+" button, select your mobile operator (SCOM, Jazz, Telenor, Zong), choose current signal strength and location, and submit your report to keep other travelers updated.',
    ),
    _FAQ(
      q: 'How to use SOS?',
      a:
          'Tap the red SOS button on the home screen or navigation bar. Press and hold to immediately broadcast an emergency distress alert with your GPS location to emergency responders and your configured contacts.',
    ),
    _FAQ(
      q: 'How to edit profile?',
      a:
          'Go to Profile tab, tap "Edit Profile", and update your full name, phone number, bio, profile photo, or emergency contact details. Changes sync automatically with your cloud account.',
    ),
    _FAQ(
      q: 'How notifications work?',
      a:
          'North Connect sends real-time push alerts for severe weather warnings, critical road blockages, and emergency SOS distress alerts in your region. You can customize Push Notifications and Alert Sounds in Settings → Safety.',
    ),
  ];

  final Set<int> _open = {};

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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                child: Row(
                  children: [
                    _roundBtn(
                      onTap: () => Navigator.maybePop(context),
                      icon: Icons.arrow_back_ios_new_rounded,
                      dark: dark,
                    ),
                    Expanded(
                      child: Text(
                        'Help & FAQs',
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ExpansionPanelList(
                      elevation: 0,
                      expandedHeaderPadding: EdgeInsets.zero,
                      expansionCallback: (i, isOpen) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (isOpen) {
                            _open.remove(i);
                          } else {
                            _open.add(i);
                          }
                        });
                      },
                      children: List.generate(_faqs.length, (i) {
                        final f = _faqs[i];
                        final open = _open.contains(i);
                        return ExpansionPanel(
                          isExpanded: open,
                          canTapOnHeader: true,
                          backgroundColor: Colors.transparent,
                          headerBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                f.q,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                          body: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16, 0, 16, 16),
                            child: Text(
                              f.a,
                              style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: subColor),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
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
        child: Icon(icon, size: 18, color: dark ? Colors.white : const Color(0xFF1E293B)),
      ),
    );
  }
}

class _FAQ {
  final String q;
  final String a;
  _FAQ({required this.q, required this.a});
}
