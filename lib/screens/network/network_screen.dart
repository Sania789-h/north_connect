import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── 1. Custom Vector Logos ──

class ScomLogo extends StatelessWidget {
  const ScomLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assests/images/iccons/scom_icon.png',
      width: 44,
      height: 44,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.cell_tower_rounded,
        color: Color(0xFF067A46),
        size: 24,
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
      width: 44,
      height: 44,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.cell_tower_rounded,
        color: Color(0xFFDC2626),
        size: 24,
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
      width: 44,
      height: 44,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.cell_tower_rounded,
        color: Color(0xFF10B981),
        size: 24,
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
      width: 44,
      height: 44,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.cell_tower_rounded,
        color: Color(0xFF0284C7),
        size: 24,
      ),
    );
  }
}

// ── 2. Network Screen ──

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Back Button ──
              Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Color(0xFF0F2C59),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // Title
              Text(
                'Network',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F2C59),
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                'Check real-time status of all\nmajor networks.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // 1. SCOM
              _buildCarrierCard(
                name: 'SCOM',
                status: 'Good',
                signalBars: 4,
                logoWidget: const ScomLogo(),
                onTap: () => _showCarrierDetailsModal(
                  context,
                  name: 'SCOM',
                  status: 'Good',
                  logoWidget: const ScomLogo(),
                  coverage: '98% 4G Coverage',
                  speed: '35 Mbps',
                  areas: 'Gilgit, Hunza, Skardu, Nagar',
                ),
              ),
              const SizedBox(height: 14),

              // 2. Jazz
              _buildCarrierCard(
                name: 'Jazz',
                status: 'Good',
                signalBars: 4,
                logoWidget: const JazzLogo(),
                onTap: () => _showCarrierDetailsModal(
                  context,
                  name: 'Jazz',
                  status: 'Good',
                  logoWidget: const JazzLogo(),
                  coverage: '92% 4G Coverage',
                  speed: '28 Mbps',
                  areas: 'Gilgit City, Skardu, Chilas',
                ),
              ),
              const SizedBox(height: 14),

              // 3. Zong 4G
              _buildCarrierCard(
                name: 'Zong 4G',
                status: 'Good',
                signalBars: 4,
                logoWidget: const ZongLogo(),
                onTap: () => _showCarrierDetailsModal(
                  context,
                  name: 'Zong 4G',
                  status: 'Good',
                  logoWidget: const ZongLogo(),
                  coverage: '90% 4G Coverage',
                  speed: '30 Mbps',
                  areas: 'Gilgit, Hunza, Ghizer',
                ),
              ),
              const SizedBox(height: 14),

              // 4. Telenor
              _buildCarrierCard(
                name: 'Telenor',
                status: 'Fair',
                signalBars: 2,
                logoWidget: const TelenorLogo(),
                onTap: () => _showCarrierDetailsModal(
                  context,
                  name: 'Telenor',
                  status: 'Fair',
                  logoWidget: const TelenorLogo(),
                  coverage: '75% 3G/4G Coverage',
                  speed: '12 Mbps (Maintenance)',
                  areas: 'Gilgit, Astore, Deosai',
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
  }) {
    final isFair = status.toLowerCase() == 'fair';
    final statusColor =
        isFair ? const Color(0xFFF59E0B) : const Color(0xFF2ECC71);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  logoWidget,
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F2C59),
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
              const Divider(color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.cell_tower_rounded, 'Coverage', coverage),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.speed_rounded, 'Average Speed', speed),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.map_rounded, 'Key Areas', areas),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: const Color(0xFF64748B),
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
              color: const Color(0xFF0F2C59),
            ),
          ),
        ),
      ],
    );
  }

  // ── Carrier Card Widget ──
  Widget _buildCarrierCard({
    required String name,
    required String status,
    required int signalBars,
    required Widget logoWidget,
    required VoidCallback onTap,
  }) {
    final isFair = status.toLowerCase() == 'fair';
    final statusColor =
        isFair ? const Color(0xFFF59E0B) : const Color(0xFF2ECC71);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: const Color(0xFF067A46).withValues(alpha: 0.08),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: const Color(0xFFEEF2F7), width: 1.0),
          ),
          child: Row(
            children: [
              // Logo
              SizedBox(
                width: 56,
                height: 44,
                child: Center(child: logoWidget),
              ),
              const SizedBox(width: 12),

              // Name & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F2C59),
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

              // Signal Bars
              _buildSignalBars(signalBars, isFair),
            ],
          ),
        ),
      ),
    );
  }

  // Signal bars widget matching screenshot style
  Widget _buildSignalBars(int activeBars, bool isFair) {
    final activeColor = isFair
        ? const Color(0xFFF59E0B)
        : const Color(0xFF2ECC71);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        final isActive = index < activeBars;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 5,
          height: (index + 1) * 7.0 + 4,
          decoration: BoxDecoration(
            color: isActive ? activeColor : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}