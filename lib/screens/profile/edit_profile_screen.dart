import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/colors.dart';
import '../../services/mock_database_service.dart';
import '../../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentProfile;

  const EditProfileScreen({super.key, required this.currentProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  late String _selectedAvatarUrl;
  bool _isLoading = false;

  final List<String> presetAvatars = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=300',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300',
    'https://images.unsplash.com/photo-1628157582853-a796fa650a6a?w=300',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=300',
  ];

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    final metaName = user?.userMetadata is Map
        ? (((user!.userMetadata as Map)['full_name'] as String?) ??
                ((user.userMetadata as Map)['name'] as String?) ??
                '')
            .trim()
        : '';
    final fallbackName = metaName.isNotEmpty
        ? metaName
        : (user?.email ?? '').contains('@')
            ? user!.email!.split('@').first
            : 'User';
    final fallbackEmail = user?.email ?? '';
    final fallbackPhone = user?.phone ?? '';

    final profileName =
        (widget.currentProfile['full_name'] as String? ?? '').trim();
    final profileEmail =
        (widget.currentProfile['email'] as String? ?? '').trim();
    final profilePhone =
        (widget.currentProfile['phone'] as String? ?? '').trim();

    _nameController = TextEditingController(
        text: profileName.isNotEmpty ? profileName : fallbackName);
    _emailController = TextEditingController(
        text: profileEmail.isNotEmpty ? profileEmail : fallbackEmail);
    _phoneController = TextEditingController(
        text: profilePhone.isNotEmpty ? profilePhone : fallbackPhone);
    _selectedAvatarUrl = widget.currentProfile['avatar_url'] as String? ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _initial {
    final name =
        _nameController.text.trim().isEmpty ? 'U' : _nameController.text.trim();
    return name[0].toUpperCase();
  }

  Future<void> _showAvatarPicker() async {
    HapticFeedback.lightImpact();
    final choice = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
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
                      borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(height: 18),
            Text(
              'Change Profile Photo',
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: List.generate(presetAvatars.length, (i) {
                final url = presetAvatars[i];
                final selected = _selectedAvatarUrl == url;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedAvatarUrl = url);
                    Navigator.pop(context, 1);
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: selected
                                  ? const Color(0xFF067A46)
                                  : Colors.transparent,
                              width: 3.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(url, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                            return Container(
                              color: const Color(0xFFF0F4F8),
                              child: const Icon(Icons.person_rounded,
                                  size: 30, color: Color(0xFF94A3B8)),
                            );
                          }),
                        ),
                      ),
                      if (selected)
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(0xFF067A46),
                            child: Icon(Icons.check_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    if (choice != null && mounted) setState(() {});
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    final currentUser = Supabase.instance.client.auth.currentUser;
    final updatedProfile = {
      'id': currentUser?.id ?? 'local',
      'full_name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'avatar_url': _selectedAvatarUrl,
      'bio': widget.currentProfile['bio'] ?? '',
      'location': widget.currentProfile['location'] ?? 'Gilgit-Baltistan',
      // Keep email only locally for display — auth.users holds the real email
      'email': _emailController.text.trim(),
    };

    debugPrint("_saveProfile: avatar_url=$_selectedAvatarUrl");

    // Build the profiles table payload (no 'email' column in DB)
    final dbPayload = <String, dynamic>{
      'id': currentUser?.id,
      'full_name': updatedProfile['full_name'],
      'phone': updatedProfile['phone'],
      'avatar_url': updatedProfile['avatar_url'],
      'bio': updatedProfile['bio'],
      'location': updatedProfile['location'],
    };

    try {
      if (currentUser != null) {
        await Future.wait([
          Supabase.instance.client
              .from('profiles')
              .upsert(dbPayload)
              .timeout(const Duration(seconds: 10)),
          Supabase.instance.client.auth
              .updateUser(
                UserAttributes(
                  data: {
                    'full_name': _nameController.text.trim(),
                    'avatar_url': _selectedAvatarUrl,
                  },
                  email: _emailController.text.trim().isNotEmpty &&
                          _emailController.text.trim().contains('@')
                      ? _emailController.text.trim()
                      : null,
                ),
              )
              .timeout(const Duration(seconds: 10))
              .catchError((e) {
            debugPrint("Auth metadata update failed (non-fatal): $e");
            return null;
          }),
        ]);
      }
    } catch (e) {
      debugPrint("DB upsert failed on save, writing locally: $e");
    }

    MockDatabaseService.updateOfflineProfile(
        Map<String, dynamic>.from(updatedProfile));
    debugPrint("MockDatabaseService updated locally with avatar=${updatedProfile['avatar_url']}");

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully',
            style: GoogleFonts.outfit()),
        backgroundColor: const Color(0xFF067A46),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    setState(() => _isLoading = false);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _roundBtn(
                      onTap: () => Navigator.maybePop(context),
                      icon: Icons.arrow_back_ios_new_rounded,
                    ),
                    Expanded(
                      child: Text(
                        'Edit Profile',
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
                const SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border:
                                Border.all(color: Colors.white, width: 5),
                          ),
                          child: ClipOval(
                            child: _selectedAvatarUrl.isNotEmpty
                                ? Image.network(
                                    _selectedAvatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _avatarFallback(),
                                  )
                                : _avatarFallback(),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: _showAvatarPicker,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFF067A46),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF067A46)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.photo_camera_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                _fieldLabel('Full Name'),
                const SizedBox(height: 8),
                _styledField(
                  controller: _nameController,
                  hint: 'Enter your full name',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Full Name is required'
                          : null,
                ),
                const SizedBox(height: 24),
                _fieldLabel('Email'),
                const SizedBox(height: 8),
                _styledField(
                  controller: _emailController,
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Email is required';
                    if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                        .hasMatch(s)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _fieldLabel('Phone Number'),
                const SizedBox(height: 8),
                _styledField(
                  controller: _phoneController,
                  hint: 'e.g. +92 300 1234567',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 34),
                CustomButton(
                  text: "Save Changes",
                  onPressed: _saveProfile,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return AnimatedBuilder(
      animation: Listenable.merge([_nameController]),
      builder: (_, __) => Container(
        color: const Color(0xFF1B547A),
        child: Center(
          child: Text(
            _initial,
            style: GoogleFonts.outfit(
              fontSize: 46,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
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

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Color(0xFF067A46), width: 1.6),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.2),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.6),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
