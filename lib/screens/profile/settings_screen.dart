import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/settings_notifier.dart';
import '../../services/settings_service.dart';
import '../main_navigation_screen.dart';

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
        duration: const Duration(seconds: 1, milliseconds: 400),
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

  Future<void> _pickLanguage() async {
    HapticFeedback.selectionClick();
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SelectionSheet(
        title: 'Language',
        options: SettingsService.languages,
        current: _notifier.language,
      ),
    );
    if (chosen == null || chosen == _notifier.language) return;
    await _notifier.setLanguage(chosen);
    if (mounted) _toast('Language changed to $chosen');
  }

  Future<void> _pickUnits() async {
    HapticFeedback.selectionClick();
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SelectionSheet(
        title: 'Units',
        options: SettingsService.unitsOptions,
        current: _notifier.units,
      ),
    );
    if (chosen == null || chosen == _notifier.units) return;
    await _notifier.setUnits(chosen);
    if (mounted) _toast('Units changed to $chosen');
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
                        _toggleTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Push Notifications',
                          value: s.pushNotifications,
                          onChanged: _setPush,
                          dark: dark,
                          textColor: textColor,
                        ),
                        Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: dark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFF1F5F9)),
                        _toggleTile(
                          icon: Icons.volume_up_rounded,
                          title: 'Alert Sounds',
                          value: s.alertSounds,
                          onChanged: _setSounds,
                          dark: dark,
                          textColor: textColor,
                        ),
                        Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: dark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFF1F5F9)),
                        _toggleTile(
                          icon: dark ? Icons.dark_mode_rounded : Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          value: s.darkMode,
                          onChanged: _setDark,
                          dark: dark,
                          textColor: textColor,
                        ),
                        Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: dark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFF1F5F9)),
                        _navTile(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          value: s.language,
                          onTap: _pickLanguage,
                          dark: dark,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: dark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFF1F5F9)),
                        _navTile(
                          icon: Icons.info_outline_rounded,
                          title: 'Units',
                          value: s.units,
                          onTap: _pickUnits,
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
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                child: Text(
                  'Changes save automatically & apply instantly.',
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
                color: dark ? Colors.black.withValues(alpha: 0.25) : const Color(0x0F000000),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon,
            size: 18, color: dark ? Colors.white : const Color(0xFF1E293B)),
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
              Icon(icon, size: 28, color: textColor),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Transform.scale(
                scale: 1.1,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.white,
                  activeTrackColor: dark
                      ? const Color(0xFF22C55E).withValues(alpha: 0.9)
                      : const Color(0xFF067A46).withValues(alpha: 0.9),
                  inactiveTrackColor:
                      dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
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
    required String value,
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
              Icon(icon, size: 28, color: textColor),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: subColor,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  size: 22, color: subColor),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// Selection Bottom Sheet
// ═══════════════════════════════════════════════
class _SelectionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String current;

  const _SelectionSheet({
    required this.title,
    required this.options,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: dark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text('Select $title',
                    style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(options.length, (i) {
            final opt = options[i];
            final isSelected = opt == current;
            final isLast = i == options.length - 1;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context, opt),
                borderRadius: BorderRadius.circular(14),
                splashColor: const Color(0xFF067A46).withValues(alpha: 0.05),
                highlightColor: const Color(0xFF067A46).withValues(alpha: 0.025),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? (dark ? const Color(0xFF22C55E) : const Color(0xFF067A46))
                                    : textColor,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFF067A46),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                          height: 1,
                          indent: 12,
                          endIndent: 12,
                          color: dark
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFF1F5F9)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
