import 'package:flutter/material.dart';
import '../core/constants/app_images.dart';

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
      duration: const Duration(milliseconds: 1900),
    )..repeat();
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.14).animate(
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
    const double innerDiameter = 210.0;
    const double outerPinkDiameter = innerDiameter + 56;
    const double pulsePadding = 10;

    return SizedBox(
      width: outerPinkDiameter + pulsePadding * 2,
      height: outerPinkDiameter + pulsePadding * 2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ── Soft animated outer red glow pulse (aura) ──
          if (!widget.isLoading && !widget.isDisabled)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) {
                final progress =
                    ((_pulseAnim.value - 1.0) / 0.14).clamp(0.0, 1.0);
                final opacity = (1.0 - progress) * 0.55;
                return Transform.scale(
                  scale: _pulseAnim.value,
                  child: Container(
                    width: outerPinkDiameter,
                    height: outerPinkDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        stops: const [0.55, 1.0],
                        colors: [
                          const Color(0xFFFFB4B4).withValues(alpha: opacity * 0.7),
                          const Color(0xFFFFC5C5).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // ── Outer soft pink ring container (as in ref) ──
          Container(
            width: outerPinkDiameter,
            height: outerPinkDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFE6E7),
              border: Border.all(
                color: const Color(0xFFFFC2C4),
                width: 2.0,
              ),
            ),
          ),

          // ── Red circular interactive button (gradient + shadow) ──
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
              duration: const Duration(milliseconds: 140),
              scale: widget.isLoading ? 0.97 : (_isPressed ? 0.94 : 1.0),
              curve: Curves.easeInOut,
              child: Container(
                width: innerDiameter,
                height: innerDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: widget.isDisabled
                        ? const [Color(0xFFA9B1BD), Color(0xFF6B7280)]
                        : const [Color(0xFFFF5757), Color(0xFFE11919)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isDisabled
                              ? const Color(0xFF7B8794)
                              : const Color(0xFFFF3535))
                          .withValues(alpha: 0.42),
                      blurRadius: 28,
                      spreadRadius: 3,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.45),
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 46,
                            height: 46,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.8,
                              color: Colors.white,
                              backgroundColor: Colors.white24,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: Image.asset(
                              AppImages.sosLogo,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              isAntiAlias: true,
                            ),
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
