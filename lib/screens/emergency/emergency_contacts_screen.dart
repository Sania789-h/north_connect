import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main_navigation_screen.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  String _userContactName = '';
  String _userContactPhone = '';
  bool _loadingUserContact = true;

  @override
  void initState() {
    super.initState();
    _loadUserContact();
  }

  Future<void> _loadUserContact() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('emergency_contact_name, emergency_contact_phone')
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null && mounted) {
          setState(() {
            _userContactName = (profile['emergency_contact_name'] as String? ?? '').trim();
            _userContactPhone = (profile['emergency_contact_phone'] as String? ?? '').trim();
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading user emergency contact: $e");
    } finally {
      if (mounted) {
        setState(() => _loadingUserContact = false);
      }
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

  Future<void> _confirmAndCall(String name, String phone) async {
    HapticFeedback.heavyImpact();
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) {
      _toast('No valid phone number configured for $name');
      return;
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFFEF4444), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Call $name?',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: dark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to dial $phone ($name)?',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: dark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: dark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Call Now', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final uri = Uri.parse('tel:$cleanPhone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (mounted) {
        _toast('Could not open phone dialer for $phone');
      }
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit()),
        backgroundColor: const Color(0xFF067A46),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardBg = dark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF1E293B);
    final subColor = dark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

    final List<Map<String, String>> officialContacts = [
      {
        'title': 'Police Emergency',
        'subtitle': 'Law Enforcement & Immediate Assistance',
        'number': '15',
        'icon': 'police',
      },
      {
        'title': 'Rescue 1122',
        'subtitle': 'Disaster, Ambulance & Mountain Rescue',
        'number': '1122',
        'icon': 'rescue',
      },
      {
        'title': 'Hospital & Medical Emergency',
        'subtitle': 'DHQ Hospital Gilgit / Emergency Ward',
        'number': '05811-920200',
        'icon': 'hospital',
      },
      {
        'title': 'Fire & Disaster Rescue',
        'subtitle': 'Fire Department Emergency Line',
        'number': '16',
        'icon': 'fire',
      },
    ];

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
                        'Emergency Contacts',
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

            // Warning Notice
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap any service below to safely call emergency services in Gilgit-Baltistan. A confirmation dialog will appear before placing the call.',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: dark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Official Emergency Contacts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Official Emergency Services',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...officialContacts.map((c) => _contactCard(
                          title: c['title']!,
                          subtitle: c['subtitle']!,
                          number: c['number']!,
                          iconType: c['icon']!,
                          cardBg: cardBg,
                          textColor: textColor,
                          subColor: subColor,
                          dark: dark,
                        )),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Personal Emergency Contact
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Emergency Contact',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_loadingUserContact)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFF067A46)),
                        ),
                      )
                    else if (_userContactPhone.isNotEmpty)
                      _contactCard(
                        title: _userContactName.isNotEmpty ? _userContactName : 'Personal Contact',
                        subtitle: 'Your configured emergency contact',
                        number: _userContactPhone,
                        iconType: 'user',
                        cardBg: cardBg,
                        textColor: textColor,
                        subColor: subColor,
                        dark: dark,
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: dark ? Colors.black.withValues(alpha: 0.3) : const Color(0x0E000000),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person_add_disabled_rounded, size: 36, color: subColor),
                            const SizedBox(height: 8),
                            Text(
                              'No personal emergency contact added yet.',
                              style: GoogleFonts.outfit(fontSize: 14, color: subColor),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'You can set your personal contact from your Profile settings.',
                              style: GoogleFonts.outfit(fontSize: 12, color: subColor),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _contactCard({
    required String title,
    required String subtitle,
    required String number,
    required String iconType,
    required Color cardBg,
    required Color textColor,
    required Color subColor,
    required bool dark,
  }) {
    IconData icon;
    Color iconColor;

    switch (iconType) {
      case 'police':
        icon = Icons.local_police_rounded;
        iconColor = const Color(0xFF2563EB);
        break;
      case 'rescue':
        icon = Icons.medical_services_rounded;
        iconColor = const Color(0xFFDC2626);
        break;
      case 'hospital':
        icon = Icons.local_hospital_rounded;
        iconColor = const Color(0xFF059669);
        break;
      case 'fire':
        icon = Icons.local_fire_department_rounded;
        iconColor = const Color(0xFFD97706);
        break;
      default:
        icon = Icons.person_pin_rounded;
        iconColor = const Color(0xFF7C3AED);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black.withValues(alpha: 0.3) : const Color(0x0E000000),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _confirmAndCall(title, number),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF067A46).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.call_rounded, color: Color(0xFF067A46), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        number,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF067A46),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        child: Icon(
          icon,
          size: 18,
          color: dark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
    );
  }
}
