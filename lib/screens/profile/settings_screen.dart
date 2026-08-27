import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_service.dart';
import '../../services/settings_notifier.dart';
import '../auth/login_screen.dart';
import '../emergency/emergency_contacts_screen.dart';
import '../main_navigation_screen.dart';
import '../sos/sos_screen.dart';
import 'about_app_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _textColor = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF64748B);

  final SettingsNotifier _notifier = SettingsNotifier.instance;

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_onSettings);
    if (!_notifier.loaded) {
      _notifier.load().ignore();
    }
  }

  @override
  void dispose() {
    _notifier.removeListener(_onSettings);
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

  void _onSettings() {
    if (mounted) setState(() {});
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit()),
        backgroundColor: const Color(0xFF067A46),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1, milliseconds: 600),
      ),
    );
  }

  Future<void> _setPush(bool v) async {
    HapticFeedback.lightImpact();
    await _notifier.setPushNotifications(v);
    if (mounted) _toast(v ? 'Push notifications enabled' : 'Push notifications disabled');
  }

  Future<void> _setSounds(bool v) async {
    HapticFeedback.lightImpact();
    await _notifier.setAlertSounds(v);
    if (mounted) _toast(v ? 'Alert sounds enabled' : 'Alert sounds disabled');
  }

  Future<void> _setDark(bool v) async {
    HapticFeedback.lightImpact();
    await _notifier.setDarkMode(v);
    if (mounted) _toast(v ? 'Dark mode enabled' : 'Dark mode disabled');
  }

  Future<void> _changePassword() async {
    HapticFeedback.selectionClick();
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = dark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF1E293B);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Form(
            key: formKey,
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
                Text(
                  'Change Password',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                  style: GoogleFonts.outfit(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter new password',
                    labelStyle: GoogleFonts.outfit(color: dark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF067A46), width: 1.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: true,
                  validator: (v) => (v != passCtrl.text) ? 'Passwords do not match' : null,
                  style: GoogleFonts.outfit(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    hintText: 'Re-enter new password',
                    labelStyle: GoogleFonts.outfit(color: dark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF067A46), width: 1.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      try {
                        await Supabase.instance.client.auth.updateUser(
                          UserAttributes(password: passCtrl.text.trim()),
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          _toast('Password updated successfully');
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          _toast('Failed to update password: $e');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF067A46),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Update Password', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: dark ? Colors.white : _textColor,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of North Connect?',
          style: GoogleFonts.outfit(
            color: dark ? const Color(0xFFCBD5E1) : _textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: dark ? const Color(0xFFCBD5E1) : _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Logout', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AuthService().signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark;
    final bg = dark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardBg = dark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = dark ? Colors.white : _textColor;
    final subColor = dark ? const Color(0xFFCBD5E1) : _textSecondary;

    if (!_notifier.loaded) {
      return Scaffold(
        backgroundColor: bg,
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF067A46)),
          ),
        ),
      );
    }

    final s = _notifier.settings;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Bar
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
                        'Settings',
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

            // ═══════════════════════════════════════════════
            // SECTION 1: ACCOUNT
            // ═══════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Text(
                  'ACCOUNT',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: const Color(0xFF067A46),
                  ),
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
                        _navTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profile',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            );
                          },
                          dark: dark,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        _divider(dark),
                        _navTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Change Password',
                          onTap: _changePassword,
                          dark: dark,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        _divider(dark),
                        _navTile(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          onTap: _logout,
                          dark: dark,
                          textColor: const Color(0xFFEF4444),
                          subColor: const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ═══════════════════════════════════════════════
            // SECTION 2: SAFETY
            // ═══════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(
                  'SAFETY',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: const Color(0xFF067A46),
                  ),
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
                        _navTile(
                          icon: Icons.contact_phone_outlined,
                          title: 'Emergency Contacts',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
                            );
                          },
                          dark: dark,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        _divider(dark),
                        _navTile(
                          icon: Icons.sos_rounded,
                          title: 'SOS Settings',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SOSSenderScreen()),
                            );
                          },
                          dark: dark,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        _divider(dark),
                        _toggleTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Push Notifications',
                          value: s.pushNotifications,
                          onChanged: _setPush,
                          dark: dark,
                          textColor: textColor,
                        ),
                        _divider(dark),
                        _toggleTile(
                          icon: Icons.volume_up_rounded,
                          title: 'Alert Sounds',
                          value: s.alertSounds,
                          onChanged: _setSounds,
                          dark: dark,
                          textColor: textColor,
                        ),
                        _divider(dark),
                        _toggleTile(
                          icon: dark ? Icons.dark_mode_rounded : Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          value: s.darkMode,
                          onChanged: _setDark,
                          dark: dark,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ═══════════════════════════════════════════════
            // SECTION 3: INFORMATION
            // ═══════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(
                  'INFORMATION',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: const Color(0xFF067A46),
                  ),
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
                        _navTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & FAQ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                            );
                          },
                          dark: dark,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        _divider(dark),
                        _navTile(
                          icon: Icons.info_outline_rounded,
                          title: 'About North Connect',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AboutAppScreen()),
                            );
                          },
                          dark: dark,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        _divider(dark),
                        _navTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                            );
                          },
                          dark: dark,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        _divider(dark),
                        _navTile(
                          icon: Icons.description_outlined,
                          title: 'Terms & Conditions',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
                            );
                          },
                          dark: dark,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Text(
                  'North Connect v1.0.0+1 • Gilgit-Baltistan',
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

  Widget _divider(bool dark) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
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
              color: dark ? Colors.black.withValues(alpha: 0.25) : const Color(0x0F000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: dark ? Colors.white : const Color(0xFF1E293B)),
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool dark,
    required Color textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        splashColor: const Color(0xFF067A46).withValues(alpha: 0.05),
        highlightColor: const Color(0xFF067A46).withValues(alpha: 0.025),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 26, color: textColor),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Transform.scale(
                scale: 1.0,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: Colors.white,
                  activeTrackColor: dark
                      ? const Color(0xFF22C55E).withValues(alpha: 0.9)
                      : const Color(0xFF067A46).withValues(alpha: 0.9),
                  inactiveTrackColor: dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  inactiveThumbColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
    required bool dark,
    required Color textColor,
    required Color subColor,
  }) {
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
              Icon(icon, size: 26, color: textColor),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 10),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: subColor,
                  ),
                ),
              ],
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 22, color: subColor),
            ],
          ),
        ),
      ),
    );
  }
}
