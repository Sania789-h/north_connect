import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/colors.dart';
import '../../services/auth_service.dart';
import '../../services/mock_database_service.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>?> getProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    // Check offline profile state first
    if (MockDatabaseService.offlineProfile != null) {
      return MockDatabaseService.offlineProfile;
    }

    final fallbackName = user.userMetadata?['full_name'] ?? 
        (user.email != null && user.email!.contains('@') ? user.email!.split('@').first : 'User');

    final fallbackProfile = {
      'id': user.id,
      'full_name': fallbackName,
      'email': user.email ?? '',
      'phone': '',
      'bio': 'Offline Profile Mode',
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
        });

        final newData = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        return newData;
      } catch (dbErr) {
        debugPrint("Error writing profile to database, using fallback: $dbErr");
        return fallbackProfile;
      }
    } catch (e) {
      debugPrint("Error reading profile from database, using fallback: $e");
      return fallbackProfile;
    }
  }

  Future<void> logout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
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
                    child: Icon(Icons.person_off_rounded, size: 40, color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 16),
                  Text("Unable to load profile",
                      style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 15)),
                ],
              ),
            );
          }

          final profile = snapshot.data!;
          final name = profile['full_name'] ?? 'User';
          final email = profile['email'] ?? '';
          final phone = profile['phone'] ?? '';
          final bio = profile['bio'] ?? '';
          final avatarUrl = profile['avatar_url'] as String? ?? '';
          final gender = profile['gender'] as String? ?? 'Not specified';
          final location = profile['location'] as String? ?? 'Not specified';
          final emergencyName = profile['emergency_contact_name'] as String? ?? '';
          final emergencyPhone = profile['emergency_contact_phone'] as String? ?? '';
          final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF1E3A2F),
                              Color(0xFF0D281E),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -60,
                        right: -60,
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondary.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -80,
                        left: -40,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.03),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 80,
                        left: -20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondary.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -50),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final didUpdate = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(currentProfile: profile),
                                  ),
                                );
                                if (didUpdate == true && mounted) setState(() {});
                              },
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.12),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 46,
                                      backgroundColor: AppColors.secondary,
                                      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                                      child: avatarUrl.isEmpty
                                          ? Text(
                                              initial,
                                              style: GoogleFonts.outfit(
                                                fontSize: 36,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2.5),
                                    ),
                                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              name,
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (bio.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  bio,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildInfoChip(Icons.email_outlined, email),
                              ],
                            ),
                            if (phone.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildInfoChip(Icons.phone_outlined, phone),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem("Trips", "12", Icons.explore_rounded, AppColors.primary),
                              _buildStatDivider(),
                              _buildStatItem("Reviews", "8", Icons.star_rounded, AppColors.secondary),
                              _buildStatDivider(),
                              _buildStatItem("Photos", "46", Icons.photo_library_rounded, Colors.blue),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle("Traveler Information"),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.location_on_outlined, "Home Base", location, Colors.redAccent),
                            const Divider(height: 24, thickness: 0.5),
                            _buildInfoRow(Icons.face_rounded, "Gender", gender, Colors.blue),
                            if (emergencyName.isNotEmpty || emergencyPhone.isNotEmpty) ...[
                              const Divider(height: 24, thickness: 0.5),
                              _buildInfoRow(
                                Icons.emergency_share_outlined, 
                                "Emergency Contact", 
                                "${emergencyName.isNotEmpty ? emergencyName : 'Not Set'}${emergencyPhone.isNotEmpty ? ' ($emergencyPhone)' : ''}", 
                                AppColors.error
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Settings"),

                      const SizedBox(height: 12),

                      _buildMenuCard(
                        items: [
                          _MenuItem(
                            icon: Icons.person_outline_rounded,
                            title: "Edit Profile",
                            subtitle: "Name, phone, bio",
                            color: AppColors.primary,
                            onTap: () async {
                              final didUpdate = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(currentProfile: profile),
                                ),
                              );
                              if (didUpdate == true && mounted) setState(() {});
                            },
                          ),
                          _MenuItem(
                            icon: Icons.notifications_outlined,
                            title: "Notifications",
                            subtitle: "Alert preferences",
                            color: AppColors.warning,
                            onTap: () {},
                          ),
                          _MenuItem(
                            icon: Icons.security_rounded,
                            title: "Privacy & Security",
                            subtitle: "Account protection",
                            color: Colors.blue,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Support"),

                      const SizedBox(height: 12),

                      _buildMenuCard(
                        items: [
                          _MenuItem(
                            icon: Icons.info_outline_rounded,
                            title: "About App",
                            subtitle: "Version 1.0.0",
                            color: AppColors.textSecondary,
                            onTap: () {},
                          ),
                          _MenuItem(
                            icon: Icons.help_outline_rounded,
                            title: "Help & Support",
                            subtitle: "FAQs and contact us",
                            color: Colors.teal,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: logout,
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: Text("Sign Out",
                              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: AppColors.error.withValues(alpha: 0.25)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.grey.withValues(alpha: 0.12),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMenuCard({required List<_MenuItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              if (index > 0)
                Divider(height: 1, indent: 60, color: Colors.grey.withValues(alpha: 0.08)),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(20) : Radius.zero,
                    bottom: index == items.length - 1 ? const Radius.circular(20) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                item.subtitle,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
