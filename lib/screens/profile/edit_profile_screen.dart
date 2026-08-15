import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/profile_service.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_button.dart';
import 'profile_screen.dart';

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
  late TextEditingController _bioController;
  late TextEditingController _locationController;

  late String _selectedAvatarUrl;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  final List<String> presetAvatars = [
    'https://i.pravatar.cc/300?img=11',
    'https://i.pravatar.cc/300?img=12',
    'https://i.pravatar.cc/300?img=33',
    'https://i.pravatar.cc/300?img=47',
    'https://i.pravatar.cc/300?img=68',
    'https://i.pravatar.cc/300?img=53',
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
    _bioController = TextEditingController(
        text: (widget.currentProfile['bio'] as String? ?? '').trim());
    _locationController = TextEditingController(
        text: (widget.currentProfile['location'] as String? ?? 'Gilgit-Baltistan').trim());
    _selectedAvatarUrl = widget.currentProfile['avatar_url'] as String? ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileScreen(showBackButton: true),
        ),
      );
    }
  }

  String get _initial {
    final name =
        _nameController.text.trim().isEmpty ? 'U' : _nameController.text.trim();
    return name[0].toUpperCase();
  }


  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('Uploading profile picture...',
                  style: GoogleFonts.outfit()),
            ],
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFF067A46),
        ),
      );

      final String? uploadedUrl = await ProfileService.uploadAvatar(pickedFile);

      if (!mounted) return;
      setState(() => _isUploadingImage = false);

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        setState(() => _selectedAvatarUrl = uploadedUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile picture uploaded successfully!', style: GoogleFonts.outfit()),
            backgroundColor: const Color(0xFF067A46),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Local path fallback if cloud storage bucket is unconfigured/offline
        setState(() => _selectedAvatarUrl = pickedFile.path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Picture selected & saved to profile!',
                style: GoogleFonts.outfit()),
            backgroundColor: const Color(0xFF067A46),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _promptCustomUrl() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Custom Image URL', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'https://example.com/photo.jpg',
            hintStyle: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF94A3B8)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF067A46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('Set Image', style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
    if (url != null && url.isNotEmpty) {
      setState(() => _selectedAvatarUrl = url);
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change Profile Photo',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _promptCustomUrl();
                  },
                  icon: const Icon(Icons.link_rounded, size: 18, color: Color(0xFF067A46)),
                  label: Text('Custom URL', style: GoogleFonts.outfit(color: const Color(0xFF067A46), fontWeight: FontWeight.w600)),
                )
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(ImageSource.gallery);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.photo_library_rounded, color: Color(0xFF067A46), size: 26),
                          const SizedBox(height: 6),
                          Text('Gallery', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF067A46))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(ImageSource.camera);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.camera_alt_rounded, color: Color(0xFF067A46), size: 26),
                          const SizedBox(height: 6),
                          Text('Camera', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF067A46))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Or Choose Preset Avatar',
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 10),
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
                      AvatarWidget(
                        avatarUrl: url,
                        name: 'A${i + 1}',
                        size: 80,
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

    await ProfileService.updateProfile(
      fullName: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      avatarUrl: _selectedAvatarUrl,
      bio: _bioController.text,
      location: _locationController.text,
    );

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
                      onTap: _goBack,
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
                        AvatarWidget(
                          avatarUrl: _selectedAvatarUrl,
                          name: _nameController.text,
                          size: 120,
                          backgroundColor: Colors.white,
                          border: Border.all(color: Colors.white, width: 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
                const SizedBox(height: 24),
                _fieldLabel('Location'),
                const SizedBox(height: 8),
                _styledField(
                  controller: _locationController,
                  hint: 'e.g. Gilgit-Baltistan',
                ),
                const SizedBox(height: 24),
                _fieldLabel('Bio'),
                const SizedBox(height: 8),
                _styledField(
                  controller: _bioController,
                  hint: 'Tell us a bit about yourself...',
                  maxLines: 3,
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
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
