import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/helpers.dart';
import '../../services/sos_service.dart';
import '../../widgets/sos_button.dart';

class SOSSenderScreen extends StatefulWidget {
  const SOSSenderScreen({super.key});

  @override
  State<SOSSenderScreen> createState() => _SOSSenderScreenState();
}

class _SOSSenderScreenState extends State<SOSSenderScreen> {
  final SOSService _sosService = SOSService();

  bool _loadingLocation = true;
  bool _sendingSOS = false;
  int? _callingIndex;
  String? _locationError;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });

    final result = await _sosService.getCurrentLocation();
    if (!mounted) return;

    setState(() {
      _loadingLocation = false;
      _position = result.position;
      _locationError = result.success ? null : result.errorMessage;
    });
  }

  Future<void> _handleSOS() async {
    if (_sendingSOS) return;

    if (_position == null) {
      Helpers.showSnackBar(
        context,
        _locationError ?? 'Location permission enable karein aur dubara try karein.',
      );
      return;
    }

    final darkDialog = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = darkDialog ? const Color(0xFF1E293B) : Colors.white;
    final dialogTextPrimary = darkDialog ? Colors.white : const Color(0xFF1E293B);
    final dialogTextSecondary = darkDialog ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563);
    final dialogCancelColor = darkDialog ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: dialogBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Confirm SOS',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: dialogTextPrimary),
            ),
            content: Text(
              'Are you sure you want to send an SOS?',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: dialogTextSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                    color: dialogCancelColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B3B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Send SOS',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    setState(() => _sendingSOS = true);
    HapticFeedback.heavyImpact();

    try {
      await _sosService.sendSOSRequest(
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        locationLabel: _cityText,
      );

      if (!mounted) return;
      Helpers.showSnackBar(context, 'SOS request sent successfully.');
    } catch (e) {
      if (!mounted) return;
      Helpers.showSnackBar(context, 'SOS send nahi hua: $e');
    } finally {
      if (mounted) {
        setState(() => _sendingSOS = false);
      }
    }
  }

  Future<void> _callContact(int index) async {
    setState(() => _callingIndex = index);
    final phone = index == 0 ? '1122' : index == 1 ? '15' : '115';
    final success = await _sosService.launchPhoneCall(phone);
    if (!mounted) return;
    setState(() => _callingIndex = null);
    if (!success) {
      Helpers.showSnackBar(context, 'Dialer open nahi ho saka.');
    }
  }

  String get _cityText {
    return 'Gilgit, Pakistan';
  }

  String get _latitudeText {
    if (_position == null) return '35.9214° N';
    return '${_position!.latitude.toStringAsFixed(4)}° N';
  }

  String get _longitudeText {
    if (_position == null) return '74.3060° E';
    return '${_position!.longitude.toStringAsFixed(4)}° E';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAFB);
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFEEF1F6);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0B1F3A);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF5D697B);
    final iconColor = isDark ? Colors.white : const Color(0xFF0B1F3A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Helpers.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Emergency SOS',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      'Emergency SOS',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your location will be shared with\nemergency contacts.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SOSButton(
                      isLoading: _sendingSOS,
                      isDisabled: _loadingLocation,
                      onPressed: _handleSOS,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to Send SOS',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildLocationCard(cardBg: cardBg, cardBorder: cardBorder, textPrimary: textPrimary, textSecondary: textSecondary),
                    const SizedBox(height: 16),
                    _buildContactsCard(cardBg: cardBg, cardBorder: cardBorder, textPrimary: textPrimary, textSecondary: textSecondary, isDark: isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cards ───────────────────────────────────────────────────
  Widget _buildLocationCard({
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Location',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (_loadingLocation)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Fetching location...',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              _cityText,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _position == null
                    ? const Color(0xFFDC2626)
                    : textSecondary,
              ),
            ),
            if (_position == null && _locationError != null) ...[
              const SizedBox(height: 6),
              Text(
                _locationError!,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  color: const Color(0xFFDC2626),
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
          _locationRow(
            icon: Icons.location_on_outlined,
            label: 'Latitude: $_latitudeText',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 12),
          _locationRow(
            icon: Icons.explore_outlined,
            label: 'Longitude: $_longitudeText',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _locationRow({
    required IconData icon,
    required String label,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      children: [
        Icon(icon, size: 19, color: textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactsCard({
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Contacts',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          _contactItem(
            index: 0,
            name: 'Rescue 1122',
            subtext: '1122',
            number: '1122',
            icon: Icons.local_fire_department_rounded,
            badgeColor: const Color(0xFF0B2744),
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          _Divider(isDark: isDark),
          _contactItem(
            index: 1,
            name: 'Police',
            subtext: null,
            number: '15',
            icon: Icons.local_police_rounded,
            badgeColor: const Color(0xFF1D5FED),
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          _Divider(isDark: isDark),
          _contactItem(
            index: 2,
            name: 'Edhi Ambulance',
            subtext: null,
            number: '115',
            icon: Icons.local_hospital_rounded,
            badgeColor: const Color(0xFFB45309),
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _contactItem({
    required int index,
    required String name,
    required String? subtext,
    required String number,
    required IconData icon,
    required Color badgeColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isCalling = _callingIndex == index;
    return InkWell(
      onTap: isCalling ? null : () => _callContact(index),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  if (subtext != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtext,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isCalling)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1D5FED),
                ),
              )
            else
              Text(
                number,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        margin: const EdgeInsets.only(left: 60),
        height: 1,
        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFEDEFF4),
      ),
    );
  }
}
