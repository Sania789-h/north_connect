import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SOSButton extends StatefulWidget {
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  const SOSButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _pulseAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: false);
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.shortestSide * 0.55;
    final diameter = size < 210 ? size : 210;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (!widget.isLoading && !widget.isDisabled)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) {
                return Opacity(
                  opacity: (1 - _pulseAnim.value).clamp(0.0, 0.45),
                  child: Transform.scale(
                    scale: _pulseAnim.value,
                    child: Container(
                      width: diameter,
                      height: diameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEF4444),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          GestureDetector(
            onTapDown: widget.isLoading || widget.isDisabled
                ? null
                : (_) => setState(() => _isPressed = true),
            onTapUp: widget.isLoading || widget.isDisabled
                ? null
                : (_) {
                    setState(() => _isPressed = false);
                    widget.onPressed();
                  },
            onTapCancel: widget.isLoading || widget.isDisabled
                ? null
                : () => setState(() => _isPressed = false),
            onTap: widget.isLoading || widget.isDisabled ? null : widget.onPressed,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 120),
              scale: widget.isLoading
                  ? 0.98
                  : _isPressed
                      ? 0.90
                      : (_scaleAnim.value),
              curve: Curves.easeInOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.isDisabled
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFFFF6B6B),
                      widget.isDisabled
                          ? const Color(0xFF6B7280)
                          : const Color(0xFFDC2626),
                      widget.isDisabled
                          ? const Color(0xFF4B5563)
                          : const Color(0xFFB91C1C),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isDisabled
                              ? const Color(0xFF6B7280)
                              : const Color(0xFFDC2626))
                          .withValues(alpha: 0.5),
                      blurRadius: 28,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                      inset: true,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1.5,
                    ),
                  ),
                  child: widget.isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 46,
                            height: 46,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.5,
                              color: Colors.white,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sos_rounded,
                                size: 46,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 6,
                                    color: Color(0x66000000),
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'SOS',
                                style: GoogleFonts.outfit(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                  height: 1,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 8,
                                      color: Color(0x55000000),
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
