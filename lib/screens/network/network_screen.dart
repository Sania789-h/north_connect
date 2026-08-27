import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/helpers.dart';
import '../../models/network_model.dart';
import '../../services/network_service.dart';
import '../main_navigation_screen.dart';
import 'add_network_report_sheet.dart';

class ScomLogo extends StatelessWidget {
  const ScomLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assests/images/iccons/scom_icon.png',
      height: 38,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.cell_tower_rounded,
        color: Color(0xFF22C55E),
        size: 28,
      ),
    );
  }
}

class JazzLogo extends StatelessWidget {
  const JazzLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assests/images/iccons/jazz_icon.png',
      height: 38,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.cell_tower_rounded,
        color: Color(0xFFDC2626),
        size: 28,
      ),
    );
  }
}

class ZongLogo extends StatelessWidget {
  const ZongLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assests/images/iccons/zong_icon.png',
      height: 38,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.cell_tower_rounded,
        color: Color(0xFF22C55E),
        size: 28,
      ),
    );
  }
}

class TelenorLogo extends StatelessWidget {
  const TelenorLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assests/images/iccons/telenor_iccon.png',
      height: 38,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.cell_tower_rounded,
        color: Color(0xFF0284C7),
        size: 28,
      ),
    );
  }
}

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  late Future<List<NetworkModel>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _refreshReports();
  }

  void _refreshReports() {
    setState(() {
      _reportsFuture = NetworkService.getNetworkReports();
    });
  }

  Future<void> _handleAddReport() async {
    HapticFeedback.lightImpact();
    final result = await showModalBottomSheet<NetworkModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddNetworkReportSheet(),
    );

    if (result != null && mounted) {
      Helpers.showSnackBar(context, 'Network report submitted successfully.');
      _refreshReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F2C59);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0x0A000000);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFEEF2F6);
    final iconColor = isDark ? Colors.white : const Color(0xFF0F2C59);
    final inactiveBarColor = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
    final handleColor = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleAddReport,
        backgroundColor: const Color(0xFF067A46),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Report Status',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            _refreshReports();
          },
          color: const Color(0xFF067A46),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Helpers.pop(
                        context,
                        fallbackPage: const MainNavigationScreen(),
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Text(
                  'Network',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  'Check real-time status of all\nmajor networks.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Carrier Status Overview Cards
                _buildCarrierCard(
                  name: 'SCOM',
                  status: 'Good',
                  signalBars: 4,
                  logoWidget: const ScomLogo(),
                  isDark: isDark,
                  cardBg: cardBg,
                  shadowColor: shadowColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  inactiveBarColor: inactiveBarColor,
                  onTap: () => _showCarrierDetailsModal(
                    context,
                    name: 'SCOM',
                    status: 'Good',
                    logoWidget: const ScomLogo(),
                    coverage: '98% 4G Coverage',
                    speed: '35 Mbps',
                    areas: 'Gilgit, Hunza, Skardu, Nagar',
                    isDark: isDark,
                    sheetBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    dividerColor: dividerColor,
                    handleColor: handleColor,
                  ),
                ),
                const SizedBox(height: 14),

                _buildCarrierCard(
                  name: 'Jazz',
                  status: 'Good',
                  signalBars: 4,
                  logoWidget: const JazzLogo(),
                  isDark: isDark,
                  cardBg: cardBg,
                  shadowColor: shadowColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  inactiveBarColor: inactiveBarColor,
                  onTap: () => _showCarrierDetailsModal(
                    context,
                    name: 'Jazz',
                    status: 'Good',
                    logoWidget: const JazzLogo(),
                    coverage: '92% 4G Coverage',
                    speed: '28 Mbps',
                    areas: 'Gilgit City, Skardu, Chilas',
                    isDark: isDark,
                    sheetBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    dividerColor: dividerColor,
                    handleColor: handleColor,
                  ),
                ),
                const SizedBox(height: 14),

                _buildCarrierCard(
                  name: 'Zong 4G',
                  status: 'Good',
                  signalBars: 4,
                  logoWidget: const ZongLogo(),
                  isDark: isDark,
                  cardBg: cardBg,
                  shadowColor: shadowColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  inactiveBarColor: inactiveBarColor,
                  onTap: () => _showCarrierDetailsModal(
                    context,
                    name: 'Zong 4G',
                    status: 'Good',
                    logoWidget: const ZongLogo(),
                    coverage: '90% 4G Coverage',
                    speed: '30 Mbps',
                    areas: 'Gilgit, Hunza, Ghizer',
                    isDark: isDark,
                    sheetBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    dividerColor: dividerColor,
                    handleColor: handleColor,
                  ),
                ),
                const SizedBox(height: 14),

                _buildCarrierCard(
                  name: 'Telenor',
                  status: 'Fair',
                  signalBars: 2,
                  logoWidget: const TelenorLogo(),
                  isDark: isDark,
                  cardBg: cardBg,
                  shadowColor: shadowColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  inactiveBarColor: inactiveBarColor,
                  onTap: () => _showCarrierDetailsModal(
                    context,
                    name: 'Telenor',
                    status: 'Fair',
                    logoWidget: const TelenorLogo(),
                    coverage: '75% 3G/4G Coverage',
                    speed: '12 Mbps (Maintenance)',
                    areas: 'Gilgit, Astore, Deosai',
                    isDark: isDark,
                    sheetBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    dividerColor: dividerColor,
                    handleColor: handleColor,
                  ),
                ),
                const SizedBox(height: 28),

                // Community Network Reports Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Community Reports',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                FutureBuilder<List<NetworkModel>>(
                  future: _reportsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF067A46))),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.cell_tower_rounded, color: textSecondary, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              'No User Reports Yet',
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                            ),
                            Text(
                              'Tap "Report Status" to submit a report.',
                              style: GoogleFonts.outfit(fontSize: 12, color: textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    final reports = snapshot.data!;
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        final isPoor = report.networkStatus.toLowerCase().contains('poor') || report.networkStatus.toLowerCase().contains('no signal');
                        final statusColor = isPoor ? const Color(0xFFEF4444) : report.networkStatus.toLowerCase().contains('fair') ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      report.networkType.isNotEmpty ? report.networkType : 'Carrier Report',
                                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    report.timeAgo,
                                    style: GoogleFonts.outfit(fontSize: 12, color: textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 16, color: textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    report.location,
                                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                                  ),
                                  const Spacer(),
                                  Text(
                                    report.signalStrength,
                                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
                                  ),
                                ],
                              ),
                              if (report.description.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  report.description,
                                  style: GoogleFonts.outfit(fontSize: 13, color: textSecondary),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCarrierDetailsModal(
    BuildContext context, {
    required String name,
    required String status,
    required Widget logoWidget,
    required String coverage,
    required String speed,
    required String areas,
    required bool isDark,
    required Color sheetBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color dividerColor,
    required Color handleColor,
  }) {
    final isFair = status.toLowerCase() == 'fair';
    final statusColor = isFair ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 52, child: logoWidget),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Status: $status',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: dividerColor),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.cell_tower_rounded, 'Coverage', coverage, textSecondary, textPrimary),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.speed_rounded, 'Average Speed', speed, textSecondary, textPrimary),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.map_rounded, 'Key Areas', areas, textSecondary, textPrimary),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color iconColor, Color textPrimary, [Color? labelColor]) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: labelColor ?? iconColor,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarrierCard({
    required String name,
    required String status,
    required int signalBars,
    required Widget logoWidget,
    required VoidCallback onTap,
    required bool isDark,
    required Color cardBg,
    required Color shadowColor,
    required Color borderColor,
    required Color textPrimary,
    required Color inactiveBarColor,
  }) {
    final isFair = status.toLowerCase() == 'fair';
    final statusColor = isFair ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: const Color(0xFF22C55E).withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: logoWidget,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                _buildSignalBars(signalBars, isFair, inactiveBarColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignalBars(int activeBars, bool isFair, Color inactiveBarColor) {
    final activeColor = isFair ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        final isActive = index < activeBars;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 4.5,
          height: 8.0 + (index * 4.0),
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveBarColor,
            borderRadius: BorderRadius.circular(2.5),
          ),
        );
      }),
    );
  }
}
