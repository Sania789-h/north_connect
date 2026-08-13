import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      onPressed: () => Navigator.pop(context),
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
              const SizedBox(height: 28),

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
              const SizedBox(height: 24),
            ],
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
    final statusColor =
        isFair ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);

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
    final statusColor =
        isFair ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);

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
    final activeColor =
        isFair ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);

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
