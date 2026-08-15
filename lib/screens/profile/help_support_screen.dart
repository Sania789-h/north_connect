import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main_navigation_screen.dart';

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
              color: Colors.white,
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
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Contact Us',
                      style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text('Our team usually responds within 24 hours.',
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: const Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  _field(
                    ctrl: _contactNameCtrl,
                    label: 'Your Name',
                    hint: 'e.g. Ali Raza',
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
                        if (!_contactFormKey.currentState!.validate())
                          return;
                        _launchEmail(
                          to: 'support@northconnect.pk',
                          subject:
                              'Contact Request from ${_contactNameCtrl.text.trim()}',
                          body:
                              'Name: ${_contactNameCtrl.text.trim()}\nEmail: ${_contactEmailCtrl.text.trim()}\n\n${_contactMsgCtrl.text.trim()}',
                        ).then((_) {
                          if (mounted) {
                            Navigator.pop(context);
                            _toast(
                                'Thanks! Your message has been prepared.');
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
              color: Colors.white,
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
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Report an Issue',
                      style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text('Tell us what went wrong and we\'ll fix it fast.',
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: const Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  _field(
                    ctrl: _reportTitleCtrl,
                    label: 'Issue Title',
                    hint: 'e.g. Weather forecast not loading',
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
                        if (!_reportFormKey.currentState!.validate())
                          return;
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

  void _openLegal({required String title, required String fileName}) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LegalDocScreen(
          title: title,
          fileName: fileName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                    ),
                    Expanded(
                      child: Text(
                        'Help & Support',
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
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0E000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        _tile(
                            icon: Icons.help_outline_rounded,
                            title: 'FAQs',
                            onTap: _openFAQs),
                        const _Divider(),
                        _tile(
                            icon: Icons.mark_email_unread_outlined,
                            title: 'Contact Us',
                            onTap: _openContactUs),
                        const _Divider(),
                        _tile(
                            icon: Icons.report_gmailerrorred_rounded,
                            title: 'Report an Issue',
                            onTap: _openReportIssue,
                            textColor: const Color(0xFFB91C1C)),
                        const _Divider(),
                        _tile(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () => _openLegal(
                                title: 'Privacy Policy',
                                fileName: 'privacy_policy.md')),
                        const _Divider(),
                        _tile(
                            icon: Icons.description_outlined,
                            title: 'Terms & Conditions',
                            onTap: () => _openLegal(
                                title: 'Terms & Conditions',
                                fileName: 'terms_conditions.md')),
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
                  'Need urgent help? Call 1122 for roadside emergencies in Pakistan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
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

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFF067A46).withValues(alpha: 0.05),
        highlightColor:
            const Color(0xFF067A46).withValues(alpha: 0.025),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon,
                  size: 28,
                  color: textColor ?? const Color(0xFF1E293B)),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? const Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right_rounded,
                  size: 22, color: Color(0xFF94A3B8)),
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
    TextInputType? keyboard,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
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
                color: const Color(0xFF64748B)),
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
              color: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
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

// ═══════════════════════════════════════════════
// Divider widget
// ═══════════════════════════════════════════════
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Color(0xFFF1F5F9),
    );
  }
}

// ═══════════════════════════════════════════════
// FAQs Screen (fully self-contained)
// ═══════════════════════════════════════════════
class _FAQsScreen extends StatefulWidget {
  const _FAQsScreen();

  @override
  State<_FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<_FAQsScreen> {
  final List<_FAQ> _faqs = [
    _FAQ(
      q: 'How accurate is the weather forecast?',
      a:
          'North Connect uses a combination of global weather models and locally observed data for high-altitude regions. Forecasts update every hour; for critical decisions (e.g. crossing passes), always pair with real-time alerts and local advice.',
    ),
    _FAQ(
      q: 'How do network signal reports work?',
      a:
          'Signal strength reports are crowdsourced anonymously from North Connect users. When you travel through an area with signal, the app can automatically upload readings (if enabled). This shows a rough coverage estimate along routes.',
    ),
    _FAQ(
      q: 'How do I create an emergency alert / SOS?',
      a:
          'From the Alerts screen tap the + button, choose "Emergency / SOS", enter location & details and submit. You can also use the dedicated SOS button available on the home screen for one-tap escalation.',
    ),
    _FAQ(
      q: 'Which locations are supported?',
      a:
          'North Connect focuses on the northern regions of Pakistan — Gilgit, Baltistan, Skardu, Hunza, Naran, Kaghan, Chitral and adjacent valleys. More regions are added based on user coverage.',
    ),
    _FAQ(
      q: 'Does the app work offline?',
      a:
          'Yes. Saved locations, cached weather, downloaded alerts and profiles all work offline. New data syncs automatically once a connection is restored.',
    ),
    _FAQ(
      q: 'How can I contact support?',
      a:
          'Tap "Contact Us" on the Help & Support screen and send a message via your email app, or write directly to support@northconnect.pk — we answer within 24 hours.',
    ),
  ];

  final Set<int> _open = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                    ),
                    Expanded(
                      child: Text(
                        'FAQs',
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
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0E000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
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
                                horizontal: 16, vertical: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                f.q,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
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
                                  height: 1.45,
                                  color: const Color(0xFF475569)),
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

class _FAQ {
  final String q;
  final String a;
  _FAQ({required this.q, required this.a});
}

// ═══════════════════════════════════════════════
// Legal Document Screen
// ═══════════════════════════════════════════════
class _LegalDocScreen extends StatelessWidget {
  final String title;
  final String fileName;

  const _LegalDocScreen({required this.title, required this.fileName});

  Map<String, String> get _docs => {
        'privacy_policy.md': '''# Privacy Policy — North Connect

**Effective date:** 2026

North Connect ("we", "our") respects your privacy. This page summarises how we handle information.

## 1. Information We Collect
- **Account data**: Email, name, phone number you provide at sign-up.
- **Profile data**: Avatar, bio, home location, saved locations.
- **Usage data**: Anonymous signal reports along travel routes, alerts submitted, SOS activations.
- **Device**: Generic OS / app version (helps us fix bugs).

## 2. How We Use It
- To run the app: authenticate, sync profiles, share alerts with your emergency contacts when you explicitly trigger SOS.
- To improve: aggregate (anonymous) coverage & crash data.
- To support: respond to emails you send to support@northconnect.pk.

## 3. Sharing
We **never sell** personal data. Only share when:
- You've triggered SOS → emergency contact details shared with responders you configured.
- Required by a lawful court order.

## 4. Security
Passwords are hashed (never stored as plaintext). Traffic uses HTTPS / TLS. Database rows are row-level secured per user.

## 5. Your Rights
Access, edit, export, or delete your profile any time from Settings → Account → Delete Account, or email support@northconnect.pk.

## 6. Changes
Major changes are posted here + notified once via in-app banner.

Questions? Email us at privacy@northconnect.pk
''',
        'terms_conditions.md': '''# Terms & Conditions — North Connect

**Last updated:** 2026

## 1. Scope
These terms apply to your use of the North Connect mobile application ("the App") and any associated services. By using the App you agree to these terms.

## 2. Service Description
North Connect is a safety & travel companion focused on northern regions of Pakistan. It provides:
- Weather forecasts and warnings (best-effort basis)
- Crowdsourced network coverage estimates
- Alert publication, SOS/Emergency flows

## 3. Acceptable Use
You agree NOT to:
- Report false alerts, fake signal data or hoax SOS activations
- Attempt to access another user's account or private info
- Use the App to violate any applicable law in Pakistan

Abuses may result in account suspension without notice.

## 4. Disclaimers
Forecasts, signal data & maps are **indicative only — NOT a substitute for professional advice**. Mountain weather changes unpredictably. Always travel with a certified local guide, registered company, and proper gear when possible.

## 5. Liability
To the maximum extent permitted by law, North Connect shall not be liable for any indirect, incidental, consequential, punitive damages (including bodily injury, loss of life) arising from use of the App.

## 6. Account Termination
You may delete your account any time via Profile → About App → Delete Account, or via support email.

## 7. Applicable Law
These terms are governed by the laws of the Islamic Republic of Pakistan, with venue in Islamabad.

Contact: legal@northconnect.pk
''',
      };

  @override
  Widget build(BuildContext context) {
    final raw = _docs[fileName] ??
        'Document not found. Please contact support.';
    final paragraphs = raw.split('\n');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                      onTap: () => Navigator.maybePop(context),
                      icon: Icons.arrow_back_ios_new_rounded,
                    ),
                    Expanded(
                      child: Text(
                        title,
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
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0E000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: paragraphs.map((p) {
                      if (p.trim().isEmpty) {
                        return const SizedBox(height: 12);
                      }
                      if (p.startsWith('# ')) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Text(
                            p.substring(2),
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        );
                      }
                      if (p.startsWith('## ')) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 18, bottom: 6),
                          child: Text(
                            p.substring(3),
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF067A46),
                            ),
                          ),
                        );
                      }
                      if (p.startsWith('- ')) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 7, right: 10, left: 4),
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF067A46),
                                      shape: BoxShape.circle),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  p.substring(2),
                                  style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      height: 1.45,
                                      color: const Color(0xFF334155)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Text(
                        p,
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            height: 1.5,
                            color: const Color(0xFF334155)),
                      );
                    }).toList(),
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
