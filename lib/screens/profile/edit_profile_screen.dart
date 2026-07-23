import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/mock_database_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentProfile;

  const EditProfileScreen({super.key, required this.currentProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _emergencyContactPhoneController;

  late String _selectedAvatarUrl;
  late String _selectedGender;
  bool _isLoading = false;

  final List<String> avatars = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', // Male 1
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', // Female 1
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', // Male 2
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150', // Female 2
    'https://images.unsplash.com/photo-1628157582853-a796fa650a6a?w=150', // Male 3
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150', // Female 3
  ];

  final List<String> genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentProfile['full_name'] ?? '');
    _phoneController = TextEditingController(text: widget.currentProfile['phone'] ?? '');
    _bioController = TextEditingController(text: widget.currentProfile['bio'] ?? '');
    _locationController = TextEditingController(text: widget.currentProfile['location'] ?? '');
    _emergencyContactNameController = TextEditingController(text: widget.currentProfile['emergency_contact_name'] ?? '');
    _emergencyContactPhoneController = TextEditingController(text: widget.currentProfile['emergency_contact_phone'] ?? '');
    _selectedAvatarUrl = widget.currentProfile['avatar_url'] ?? '';
    _selectedGender = widget.currentProfile['gender'] ?? 'Other';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose Travel Avatar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedAvatarUrl == avatars[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatarUrl = avatars[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.secondary : Colors.transparent,
                            width: 3.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage: NetworkImage(avatars[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final currentUser = Supabase.instance.client.auth.currentUser!;
    final updatedProfile = {
      'id': currentUser.id,
      'email': currentUser.email ?? '',
      'full_name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
      'avatar_url': _selectedAvatarUrl,
      'gender': _selectedGender,
      'location': _locationController.text.trim(),
      'emergency_contact_name': _emergencyContactNameController.text.trim(),
      'emergency_contact_phone': _emergencyContactPhoneController.text.trim(),
    };

    try {
      await Supabase.instance.client.from('profiles').upsert(updatedProfile);
    } catch (e) {
      debugPrint("DB upsert failed on save, writing locally: $e");
    }

    // Always update offline session cache so transitions are instant & seamless
    MockDatabaseService.updateOfflineProfile(updatedProfile);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Interactive Profile Picture Selector
              GestureDetector(
                onTap: _showAvatarPicker,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: AppColors.secondary,
                        backgroundImage: _selectedAvatarUrl.isNotEmpty
                            ? NetworkImage(_selectedAvatarUrl)
                            : null,
                        child: _selectedAvatarUrl.isEmpty
                            ? const Icon(Icons.person_rounded, size: 56, color: Colors.white)
                            : null,
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              CustomTextField(
                controller: _nameController,
                hintText: "Full Name",
                prefixIcon: Icons.person_outline_rounded,
                validator: (val) => val == null || val.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _phoneController,
                hintText: "Phone Number",
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _locationController,
                hintText: "Home Base (Country / City)",
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: "Gender",
                  prefixIcon: Icon(Icons.face_rounded, color: Colors.grey),
                ),
                items: genders.map((g) {
                  return DropdownMenuItem(
                    value: g,
                    child: Text(g),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedGender = val!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _bioController,
                hintText: "Bio (Optional)",
                prefixIcon: Icons.info_outline_rounded,
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // Emergency Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Emergency Contact Info",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _emergencyContactNameController,
                hintText: "Emergency Contact Name",
                prefixIcon: Icons.contact_emergency_outlined,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _emergencyContactPhoneController,
                hintText: "Emergency Contact Phone",
                prefixIcon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 40),
              
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : CustomButton(
                      text: "Save Changes",
                      onPressed: _saveProfile,
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
