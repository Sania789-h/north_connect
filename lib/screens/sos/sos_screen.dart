import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/helpers.dart';
import '../../services/sos_service.dart';
import '../../widgets/emergency_contact_card.dart';
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

  static const List<Map<String, dynamic>> _contacts = [
    {
      'name': 'Rescue 1122',
      'phone': '1122',
      'icon': Icons.support_agent_rounded,
      'color': Color(0xFF133B5C),
    },
    {
      'name': 'Police',
      'phone': '15',
      'icon': Icons.record_voice_over_rounded,
      'color': Color(0xFF0F5EAF),
    },
    {
      'name': 'Edhi Ambulance',
      'phone': '115',
      'icon': Icons.local_hospital_rounded,
      'color': Color(0xFFB45309),
    },
  ];

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
    final success =
        await _sosService.launchPhoneCall(_contacts[index]['phone'] as String);
    if (!mounted) return;
    setState(() => _callingIndex = null);
    if (!success) {
      Helpers.showSnackBar(context, 'Dialer open nahi ho saka.');
    }
  }

  String get _locationTitle {
    if (_loadingLocation) return 'Getting location...';
    if (_position == null) return 'Location unavailable';
    return 'Current Location';
  }

  String get _locationSubtitle {
    if (_position == null) {
      return _locationError ?? 'Enable permission to fetch your location';
    }
    return 'Live GPS Coordinates';
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
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Emergency SOS',
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        leading: IconButton(
          onPressed: () => Helpers.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F2937),
            size: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  Text(
                    'Emergency SOS',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your location will be shared with\nemergency contacts.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SOSButton(
                    isLoading: _sendingSOS,
                    isDisabled: _loadingLocation,
                    onPressed: _handleSOS,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap to Send SOS',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                  const SizedBox(height: 26),
                  _buildLocationCard(),
                  const SizedBox(height: 16),
                  _buildContactsCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
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
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _locationSubtitle,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _position == null
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 14),
          if (_loadingLocation)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  width: 24,
                  height: 24,
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
              icon: Icons.whatshot_outlined,
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
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
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
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < _contacts.length; i++) ...[
            EmergencyContactCard(
              icon: _contacts[i]['icon'] as IconData,
              iconColor: _contacts[i]['color'] as Color,
              name: _contacts[i]['name'] as String,
              phoneNumber: _contacts[i]['phone'] as String,
              isLoading: _callingIndex == i,
              onCallTap: () => _callContact(i).then((_) => true),
            ),
            if (i != _contacts.length - 1)
              const Divider(
                height: 16,
                thickness: 1,
                color: Color(0xFFF0F0F0),
              ),
          ],
        ],
      ),
    );
  }
}
