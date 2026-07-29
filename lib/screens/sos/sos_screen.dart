import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
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
  final SOSService _sos = SOSService();

  bool _loadingLocation = true;
  String? _locationError;
  Position? _position;
  String _locationLabel = 'Detecting location...';

  bool _submittingSOS = false;
  int? _loadingContactIndex;

  static const List<Map<String, dynamic>> _contacts = [
    {
      'name': 'Rescue 1122',
      'phone': '1122',
      'icon': Icons.local_hospital_rounded,
      'color': Color(0xFFEF4444),
    },
    {
      'name': 'Police',
      'phone': '15',
      'icon': Icons.local_police_rounded,
      'color': Color(0xFF1E40AF),
    },
    {
      'name': 'Edhi Ambulance',
      'phone': '115',
      'icon': Icons.airport_shuttle_rounded,
      'color': Color(0xFFD97706),
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

    final res = await _sos.getCurrentLocation();
    if (!mounted) return;

    if (res.success && res.position != null) {
      final label = await _sos.buildLocationLabel(res.position!);
      if (mounted) {
        setState(() {
          _position = res.position;
          _locationLabel = label;
          _loadingLocation = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _position = null;
          _locationError = res.errorMessage;
          _locationLabel = 'Location unavailable';
          _loadingLocation = false;
        });
      }
    }
  }

  Future<bool> _confirmDialog() async {
    HapticFeedback.heavyImpact();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              ),
              child: const Icon(Icons.sos_rounded,
                  color: Color(0xFFEF4444), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Send SOS Alert?',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your GPS location will be shared with emergency contacts and local rescue services.',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: const Color(0xFF475569),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            if (_position != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 16, color: Color(0xFFEF4444)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _locationLabel,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actionsPadding:
            const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 4),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: Text(
              'Yes, Send SOS',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _onSOSPressed() async {
    if (_submittingSOS) return;

    if (_position == null) {
      HapticFeedback.heavyImpact();
      final retry = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Location Not Available',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_rounded,
                  size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 10),
              Text(
                _locationError ?? 'Please enable GPS and location permission.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 14, color: const Color(0xFF475569)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Close',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx, true);
                Geolocator.openLocationSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.settings_rounded, size: 16),
              label: Text(
                'Open Settings',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 4),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx, false);
                _loadLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                'Retry',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
      if (retry == true) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        _loadLocation();
      }
      return;
    }

    final ok = await _confirmDialog();
    if (!ok) return;

    setState(() => _submittingSOS = true);
    try {
      await _sos.sendSOSRequest(
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        locationLabel: _locationLabel,
      );
      if (mounted) {
        HapticFeedback.vibrate();
        _showSuccessSheet();
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Failed to send SOS: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) setState(() => _submittingSOS = false);
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF0FDF4),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF22C55E), size: 46),
            ),
            const SizedBox(height: 14),
            Text(
              'SOS Request Sent!',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your location has been shared. Help is on the way. Stay calm.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13.5,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            if (_position != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 18, color: Color(0xFFA16207)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locationLabel,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA16207),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 15),
                    label: Text(
                      'Close',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _sos.launchPhoneCall('1122');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.call_rounded, size: 16),
                    label: Text(
                      'Call 1122',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onContactTap(int index) async {
    final phone = _contacts[index]['phone'] as String;
    setState(() => _loadingContactIndex = index);
    final ok = await _sos.launchPhoneCall(phone);
    if (mounted) setState(() => _loadingContactIndex = null);
    if (!ok && mounted) {
      Helpers.showSnackBar(context, 'Could not open dialer for $phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBFA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Helpers.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFF1F5F9)),
            ),
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF0F2C59)),
        ),
        title: Text(
          'Emergency SOS',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadLocation,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded,
                size: 20, color: Color(0xFF0F172A)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            children: [
              _buildHeroHeader(),
              const SizedBox(height: 18),
              SOSButton(
                isLoading: _submittingSOS,
                isDisabled: _loadingLocation,
                onPressed: _onSOSPressed,
              ),
              const SizedBox(height: 14),
              Text(
                'Tap to Send SOS',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF991B1B),
                ),
              ),
              const SizedBox(height: 28),
              _buildLocationCard(),
              const SizedBox(height: 22),
              _buildContactsCard(),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sections ──────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFEE2E2),
            const Color(0xFFFFE4E6).withValues(alpha: 0.8),
            const Color(0xFFFFEBEE),
          ],
        ),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFECACA),
            ),
            child: const Icon(
              Icons.local_police_rounded,
              size: 28,
              color: Color(0xFFB91C1C),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency SOS',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7F1D1D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your location will be shared with emergency contacts.',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    height: 1.4,
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Current Location',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              if (_loadingLocation)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0EA5E9),
                  ),
                )
              else if (_locationError != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Error',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB91C1C),
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Live',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loadingLocation)
            _LoadingShimmerRow(
                label: 'Retrieving your GPS coordinates...')
          else if (_locationError != null)
            _LocationError(
              message: _locationError!,
              onRetry: _loadLocation,
              onOpenSettings: () => Geolocator.openLocationSettings(),
            )
          else
            _LocationDetails(
              label: _locationLabel,
              position: _position!,
            ),
        ],
      ),
    );
  }

  Widget _buildContactsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 3),
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
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap call button to dial instantly.',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          Column(
            children: List.generate(_contacts.length, (i) {
              final c = _contacts[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i == _contacts.length - 1 ? 0 : 10),
                child: EmergencyContactCard(
                  icon: c['icon'] as IconData,
                  iconColor: c['color'] as Color,
                  name: c['name'] as String,
                  phoneNumber: c['phone'] as String,
                  isLoading: _loadingContactIndex == i,
                  onCallTap: () => _onContactTap(i),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Small sub-widgets ─────────────────────────────────────────
class _LoadingShimmerRow extends StatelessWidget {
  final String label;
  const _LoadingShimmerRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0EA5E9),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  const _LocationError({
    required this.message,
    required this.onRetry,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    height: 1.45,
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenSettings,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF991B1B),
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.settings_rounded, size: 16),
                  label: Text(
                    'Settings',
                    style:
                        GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    'Retry',
                    style:
                        GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationDetails extends StatelessWidget {
  final String label;
  final Position position;
  const _LocationDetails({required this.label, required this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF0284C7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gilgit, Pakistan',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0C4A6E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF0369A1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFBAE6FD)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _locStat(
                  Icons.navigation_rounded,
                  'Latitude',
                  position.latitude.toStringAsFixed(6),
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: const Color(0xFFBAE6FD),
              ),
              Expanded(
                child: _locStat(
                  Icons.explore_rounded,
                  'Longitude',
                  position.longitude.toStringAsFixed(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0284C7)),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0369A1),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0C4A6E),
          ),
        ),
      ],
    );
  }
}
