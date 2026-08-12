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
  final bool showBackButton;
  const ProfileScreen({super.key, this.showBackButton = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = getProfile();
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    final String userEmail = user?.email ?? '';
    final String userPhone = user?.phone ?? '';
    final dynamic metadata = user?.userMetadata;

    final String metaAvatar = metadata is Map
        ? ((metadata['avatar_url'] as String?) ?? '').trim()
        : '';
    final String derivedName = metadata is Map
        ? ((metadata['full_name'] as String?) ??
                metadata['name'] as String? ??
                '')
            .trim()
        : '';

    final String defaultName = derivedName.isNotEmpty
        ? derivedName
        : userEmail.contains('@')
            ? userEmail.split('@').first
            : 'User';

    final fallbackProfile = <String, dynamic>{
      'id': user?.id ?? 'local',
      'full_name': defaultName,
      'email': userEmail.isEmpty ? 'user@email.com' : userEmail,
      'phone': userPhone.isEmpty ? '' : userPhone,
      'bio': '',
      'avatar_url': metaAvatar,
      'gender': 'Other',
      'location': '',
      'emergency_contact_name': '',
      'emergency_contact_phone': '',
    };

    final Map<String, dynamic> offline =
        MockDatabaseService.offlineProfile != null
            ? Map<String, dynamic>.from(MockDatabaseService.offlineProfile!)
            : <String, dynamic>{};

    if (offline.isNotEmpty) {
      debugPrint("getProfile: using offline profile. avatar_url=${offline['avatar_url']}");
      if (offline['avatar_url'] == null ||
          offline['avatar_url'].toString().trim().isEmpty) {
        offline['avatar_url'] = metaAvatar;
      }
      if (offline['full_name'] == null ||
          offline['full_name'].toString().trim().isEmpty) {
        offline['full_name'] = defaultName;
      }
      if (offline['email'] == null ||
          offline['email'].toString().trim().isEmpty) {
        offline['email'] = fallbackProfile['email'];
      }
      return offline;
    }

    if (user == null) {
      debugPrint("getProfile: user null, using fallback avatar=${fallbackProfile['avatar_url']}");
      return fallbackProfile;
    }

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (data != null) {
        final String dbName =
            (data['full_name'] as String? ?? '').toString().trim();
        final String dbPhone =
            (data['phone'] as String? ?? '').toString().trim();
        final String dbEmail =
            (data['email'] as String? ?? '').toString().trim();
        final String dbAvatar =
            (data['avatar_url'] as String? ?? '').toString().trim();

        if (dbName.isEmpty) data['full_name'] = defaultName;
        if (dbEmail.isEmpty && userEmail.isNotEmpty) data['email'] = userEmail;
        if (dbPhone.isEmpty && userPhone.isNotEmpty) data['phone'] = userPhone;
        if (dbAvatar.isEmpty && metaAvatar.isNotEmpty) {
          data['avatar_url'] = metaAvatar;
        }

        debugPrint("getProfile: loaded from DB. avatar_url=${data['avatar_url']}");

        MockDatabaseService.updateOfflineProfile(
            Map<String, dynamic>.from(data));

        return data;
      }

      try {
        debugPrint("getProfile: DB row missing, upserting default with avatar=$metaAvatar");
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'full_name': fallbackProfile['full_name'],
          'email': fallbackProfile['email'],
          'phone': fallbackProfile['phone'],
          'avatar_url': fallbackProfile['avatar_url'],
        }).timeout(const Duration(seconds: 10));

        final newData = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single()
            .timeout(const Duration(seconds: 10));

        MockDatabaseService.updateOfflineProfile(
            Map<String, dynamic>.from(newData));

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
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF067A46)));
          }

          if (snapshot.hasError) {
            debugPrint("Profile snapshot error: ${snapshot.error}");
          }

          final user = Supabase.instance.client.auth.currentUser;
          final rawMetaName = (user?.userMetadata is Map)
              ? (((user!.userMetadata as Map)['full_name'] as String?) ??
                      ((user.userMetadata as Map)['name'] as String?) ??
                      '')
                  .trim()
              : '';
          final metaEmail = user?.email ?? '';
          final String metaName = rawMetaName.isNotEmpty
              ? rawMetaName
              : metaEmail.contains('@')
                  ? metaEmail.split('@').first
                  : 'User';

          final Map<String, dynamic> profile = snapshot.data ??
              <String, dynamic>{
                'full_name': metaName,
                'email': metaEmail.isEmpty ? 'user@email.com' : metaEmail,
                'phone': user?.phone ?? '',
                'avatar_url': '',
              };

          final pName = (profile['full_name'] as String? ?? metaName)
              .toString()
              .trim();
          final name = pName.isEmpty ? metaName : pName;
          final rawEmail =
              (profile['email'] as String? ?? metaEmail).toString().trim();
          final email = rawEmail.isEmpty
              ? (metaEmail.isEmpty ? 'user@email.com' : metaEmail)
              : rawEmail;
          final rawPhone = (profile['phone'] as String? ?? '').toString().trim();
          final phone = rawPhone.isEmpty ? 'Not provided' : rawPhone;
          final rawAvatar =
              (profile['avatar_url'] as String? ?? '').toString().trim();
          final String metaAvatar2 = (user?.userMetadata is Map)
              ? (((user!.userMetadata as Map)['avatar_url'] as String?) ?? '')
                  .trim()
              : '';
          final avatarUrl =
              rawAvatar.isNotEmpty ? rawAvatar : metaAvatar2;
          debugPrint(
              "Profile build: rawAvatar=$rawAvatar metaAvatar=$metaAvatar2 finalAvatar=$avatarUrl");
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
                      if (widget.showBackButton)
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
                        )
                      else
                        const SizedBox(width: 40, height: 40),
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
                      final Map<String, dynamic> currentData =
                          Map<String, dynamic>.from(profile);
                      final didUpdate = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProfileScreen(currentProfile: currentData),
                        ),
                      );
                      if (didUpdate == true && mounted) {
                        setState(() {
                          _profileFuture = getProfile();
                        });
                      }
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
        splashColor: const Color(0xFF0F172A).withValues(alpha: 0.04),
        highlightColor:
            const Color(0xFF0F172A).withValues(alpha: 0.02),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
          child: Row(
            children: [
              Icon(icon,
                  size: 26, color: const Color(0xFF1E293B)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}
