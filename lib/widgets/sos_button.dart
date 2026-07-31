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
  late Animation<double> _pulseAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: false);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
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
    final size = MediaQuery.of(context).size.shortestSide * 0.42;
    final diameter = size.clamp(150.0, 176.0);

    return SizedBox(
      width: diameter + 18,
      height: diameter + 18,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (!widget.isLoading && !widget.isDisabled)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) {
                return Opacity(
                  opacity: (1.12 - _pulseAnim.value).clamp(0.0, 0.22),
                  child: Transform.scale(
                    scale: _pulseAnim.value,
                    child: Container(
                      width: diameter + 8,
                      height: diameter + 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF6B6B),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF7B7B).withValues(alpha: 0.32),
                            blurRadius: 22,
                            spreadRadius: 10,
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
              scale: widget.isLoading ? 0.98 : (_isPressed ? 0.94 : 1),
              curve: Curves.easeInOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.isDisabled
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFFFF6767),
                      widget.isDisabled
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFFFF2F2F),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFCE7E7),
                    width: 5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isDisabled
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFFFF7B7B))
                          .withValues(alpha: 0.36),
                      blurRadius: 20,
                      spreadRadius: 4,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.75),
                      width: 2,
                    ),
                  ),
                  child: widget.isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 38,
                            height: 38,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SOS',
                                style: GoogleFonts.outfit(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                  height: 1,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Color(0x33000000),
                                      offset: Offset(0, 1),
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
