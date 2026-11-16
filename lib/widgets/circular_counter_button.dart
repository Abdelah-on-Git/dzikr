import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class CircularCounterButton extends StatefulWidget {
  final int currentCount;
  final int repeatCount;
  final bool isCompleted;
  final VoidCallback onTap;
  final double size;

  const CircularCounterButton({
    super.key,
    required this.currentCount,
    required this.repeatCount,
    required this.isCompleted,
    required this.onTap,
    this.size = 68.0,
  });

  @override
  State<CircularCounterButton> createState() => _CircularCounterButtonState();
}

class _CircularCounterButtonState extends State<CircularCounterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  void _handleTap() {
    if (widget.isCompleted) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final countLabel = widget.repeatCount > 0
        ? '${widget.currentCount} / ${widget.repeatCount}'
        : '${widget.currentCount}';

    return Semantics(
      button: true,
      enabled: true,
      label: widget.isCompleted
          ? 'العداد مكتمل، ${widget.currentCount} من ${widget.repeatCount}'
          : 'العداد، ${widget.currentCount} من ${widget.repeatCount}',
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: _handleTap,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isCompleted
                  ? (colors.isDark ? const Color(0xFF132A17) : const Color(0xFF2E7D32))
                  : colors.accentGreen,
              border: Border.all(
                color: widget.isCompleted
                    ? colors.metallicGold
                    : Colors.white.withValues(alpha: 0.28),
                width: widget.isCompleted ? 2.0 : 1.5,
              ),
              boxShadow: widget.isCompleted
                  ? [
                      BoxShadow(
                        color: colors.metallicGold.withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: colors.greenGlow.withValues(alpha: 0.45),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: widget.isCompleted
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: colors.metallicGold,
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'تم الإنجاز (${widget.currentCount} / ${widget.repeatCount})',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                color: colors.metallicGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 9.5,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          countLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.isDark
                                ? AppColors.pitchBlack
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
