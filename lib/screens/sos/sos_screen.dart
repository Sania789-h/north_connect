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

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Confirm SOS',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            ),
            content: Text(
              'Are you sure you want to send an SOS?',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: const Color(0xFF4B5563),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF6B7280),
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
        locationLabel: _locationSubtitle,
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
    final phone = index == 0 ? '1122' : '15';
    final success = await _sosService.launchPhoneCall(phone);
    if (!mounted) return;
    setState(() => _callingIndex = null);
    if (!success) {
      Helpers.showSnackBar(context, 'Dialer open nahi ho saka.');
    }
  }

  String get _locationTitle {
    return 'Current Location';
  }

  String get _locationSubtitle {
    if (_position == null) {
      return _locationError ?? 'Enable permission to fetch your location';
    }
    return 'Gilgit, Pakistan';
  }

  String get _latitudeText {
    if (_position == null) return '--';
    return '${_position!.latitude.toStringAsFixed(4)}${String.fromCharCode(176)} N';
  }

  String get _longitudeText {
    if (_position == null) return '--';
    return '${_position!.longitude.toStringAsFixed(4)}${String.fromCharCode(176)} E';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar matching picture (Back arrow left)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Helpers.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF1E293B),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    Text(
                      'Emergency SOS',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your location will be shared with\nemergency contacts.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SOSButton(
                      isLoading: _sendingSOS,
                      isDisabled: _loadingLocation,
                      onPressed: _handleSOS,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to Send SOS',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildLocationCard(),
                    const SizedBox(height: 16),
                    _buildContactsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _locationTitle,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _locationSubtitle,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _position == null
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          if (_loadingLocation)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ),
            )
          else ...[
            _locationRow(
              icon: Icons.location_on_outlined,
              label: 'Latitude: $_latitudeText',
            ),
            const SizedBox(height: 10),
            _locationRow(
              icon: Icons.explore_outlined,
              label: 'Longitude: $_longitudeText',
            ),
          ],
        ],
      ),
    );
  }

  Widget _locationRow({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Contacts',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          // Rescue 1122 Contact
          _contactItem(
            index: 0,
            name: 'Rescue 1122',
            subtext: '1122',
            number: '1122',
            icon: Icons.health_and_safety_rounded,
            badgeColor: const Color(0xFF1B2A4A),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          // Police Contact
          _contactItem(
            index: 1,
            name: 'Police',
            subtext: null,
            number: '15',
            icon: Icons.local_police_rounded,
            badgeColor: const Color(0xFF0F5EAF),
          ),
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
  }) {
    final isCalling = _callingIndex == index;
    return InkWell(
      onTap: isCalling ? null : () => _callContact(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  if (subtext != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtext,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
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
                  color: Color(0xFF0F5EAF),
                ),
              )
            else
              Text(
                number,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
