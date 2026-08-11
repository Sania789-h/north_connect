import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/colors.dart';
import '../../services/auth_service.dart';
import '../../services/mock_database_service.dart';
import '../auth/login_screen.dart';
import '../alerts/alerts_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'about_app_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>?> getProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    if (MockDatabaseService.offlineProfile != null) {
      return MockDatabaseService.offlineProfile;
    }

    final fallbackName = user.userMetadata?['full_name'] ??
        (user.email != null && user.email!.contains('@')
            ? user.email!.split('@').first
            : 'User');

    final fallbackProfile = {
      'id': user.id,
      'full_name': fallbackName,
      'email': user.email ?? '',
      'phone': user.phone ?? '+92 300 1234567',
      'bio': '',
      'avatar_url': '',
      'gender': 'Other',
      'location': '',
      'emergency_contact_name': '',
      'emergency_contact_phone': '',
    };

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) return data;

      try {
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'full_name': fallbackName,
          'email': user.email ?? '',
          'phone': user.phone ?? '+92 300 1234567',
        });

        final newData = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        return newData;
      } catch (dbErr) {
        debugPrint(
            "Error writing profile to database, using fallback: $dbErr");
        return fallbackProfile;
      }
    } catch (e) {
      debugPrint(
          "Error reading profile from database, using fallback: $e");
      return fallbackProfile;
    }
  }

  Future<void> logout() async {
    final ok = await _confirmLogout();
    if (!ok) return;
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<bool> _confirmLogout() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text('Logout',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B))),
            content: Text('Are you sure you want to logout?',
                style: GoogleFonts.outfit(
                    color: const Color(0xFF64748B))),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF64748B))),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Logout',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _navigate(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _navigateAlerts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AlertsScreen()),
    );
  }

  void _navigateSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _navigateHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
    );
  }

  void _navigateAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutAppScreen()),
    );
  }

  void _showComingSoon(String title) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 18),
            Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: Color(0xFFF0F4F8), shape: BoxShape.circle),
                child: const Icon(Icons.rocket_launch_rounded,
                    size: 30, color: Color(0xFF067A46))),
            const SizedBox(height: 14),
            Text('$title - Coming Soon',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B))),
            const SizedBox(height: 6),
            Text('This feature is under development.',
                style: GoogleFonts.outfit(
                    fontSize: 13, color: const Color(0xFF64748B))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF067A46),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Got it',
                    style: GoogleFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF067A46)));
          }

          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_off_rounded,
                        size: 40, color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 16),
                  Text("Unable to load profile",
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF64748B), fontSize: 15)),
                ],
              ),
            );
          }

          final profile = snapshot.data!;
          final name = profile['full_name'] ?? 'Ali Raza';
          final email = (profile['email'] as String? ?? 'ali.raza@email.com')
              .trim()
              .isEmpty
              ? 'ali.raza@email.com'
              : (profile['email'] as String);
          final rawPhone = (profile['phone'] as String? ?? '').toString().trim();
          final phone = rawPhone.isEmpty ? '+92 300 1234567' : rawPhone;
          final avatarUrl = profile['avatar_url'] as String? ?? '';
          final initial =
              name.isNotEmpty ? name[0].toUpperCase() : 'U';

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF1E293B),
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 40, minHeight: 40),
                      ),
                      const Expanded(child: SizedBox()),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE2E8F0),
                        ),
                        child: ClipOval(
                          child: avatarUrl.isNotEmpty
                              ? Image.network(avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _avatarFallback(initial),
                                )
                              : _avatarFallback(initial),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFF067A46),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 22,
                            weight: 700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    email,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    phone,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 36),
                  _tile(
                    icon: Icons.edit_rounded,
                    title: 'Edit Profile',
                    onTap: () async {
                      final didUpdate = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProfileScreen(currentProfile: profile),
                        ),
                      );
                      if (didUpdate == true && mounted) setState(() {});
                    },
                  ),
                  const SizedBox(height: 6),
                  _tile(
                    icon: Icons.notifications_active_outlined,
                    title: 'My Alerts',
                    onTap: _navigateAlerts,
                  ),
                  const SizedBox(height: 6),
                  _tile(
                    icon: Icons.location_pin,
                    title: 'Saved Locations',
                    onTap: () => _showComingSoon('Saved Locations'),
                  ),
                  const SizedBox(height: 6),
                  _tile(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    onTap: _navigateSettings,
                  ),
                  const SizedBox(height: 6),
                  _tile(
                    icon: Icons.help_rounded,
                    title: 'Help & Support',
                    onTap: _navigateHelp,
                  ),
                  const SizedBox(height: 6),
                  _tile(
                    icon: Icons.info_rounded,
                    title: 'About App',
                    onTap: _navigateAbout,
                  ),
                  const SizedBox(height: 36),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: logout,
                      borderRadius: BorderRadius.circular(18),
                      splashColor:
                          const Color(0xFFEF4444).withValues(alpha: 0.08),
                      highlightColor:
                          const Color(0xFFEF4444).withValues(alpha: 0.04),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded,
                                color: Color(0xFFEF4444), size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Logout',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _avatarFallback(String initial) {
    return Container(
      color: const Color(0xFF1B547A),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.outfit(
            fontSize: 46,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        splashColor: const Color(0xFF067A46).withValues(alpha: 0.05),
        highlightColor:
            const Color(0xFF067A46).withValues(alpha: 0.025),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            children: [
              Icon(icon,
                  size: 28, color: const Color(0xFF1E293B)),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
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
}
