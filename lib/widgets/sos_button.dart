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
    final diameter = 160.0;

    return SizedBox(
      width: diameter + 40,
      height: diameter + 40,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (!widget.isLoading && !widget.isDisabled)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) {
                return Container(
                  width: diameter + 28 * _pulseAnim.value,
                  height: diameter + 28 * _pulseAnim.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF4D4D).withValues(alpha: 0.15 * (1.1 - _pulseAnim.value + 1.0)),
                  ),
                );
              },
            ),
          // Soft pink outer border ring matching picture
          Container(
            width: diameter + 18,
            height: diameter + 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFEAEB),
              border: Border.all(
                color: const Color(0xFFFFCDD2),
                width: 2,
              ),
            ),
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
              scale: widget.isLoading ? 0.96 : (_isPressed ? 0.93 : 1),
              curve: Curves.easeInOut,
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isDisabled
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: widget.isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      )
                    : ClipOval(
                        child: ColorFiltered(
                          colorFilter: widget.isDisabled
                              ? const ColorFilter.matrix(<double>[
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0,      0,      0,      1, 0,
                                ])
                              : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                          child: Image.asset(
                            'assests/images/sos_logo.png',
                            fit: BoxFit.cover,
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
