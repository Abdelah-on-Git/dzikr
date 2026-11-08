import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/zikr_item.dart';
import '../theme/app_colors.dart';

class ZikrCard extends StatefulWidget {
  final ZikrItem item;
  final int currentCount;
  final bool isCompleted;
  final double fontScale;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;

  const ZikrCard({
    super.key,
    required this.item,
    required this.currentCount,
    required this.isCompleted,
    required this.fontScale,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
  });

  @override
  State<ZikrCard> createState() => _ZikrCardState();
}

class _ZikrCardState extends State<ZikrCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
    widget.onIncrement();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  void _copyText(BuildContext context, AppThemeColors colors) {
    Clipboard.setData(ClipboardData(text: widget.item.text));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ الذكر إلى الحافظة',
          style: TextStyle(color: colors.textPrimary),
        ),
        backgroundColor: colors.elevatedSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final progress = (widget.item.repeatCount > 0)
        ? (widget.currentCount / widget.item.repeatCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isCompleted
              ? colors.accentGreen.withValues(alpha: 0.45)
              : colors.hairline,
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: widget.isCompleted
            ? [
                BoxShadow(
                  color: colors.greenGlow.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: colors.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info: Repeat text pill + Circular progress ring + Decrement/Reset actions + Copy
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                // Repetition Badge (Islamic Gold accent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.badgeGoldBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.badgeGoldBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat_rounded,
                        size: 14,
                        color: colors.metallicGold,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.item.repeatText,
                        style: TextStyle(
                          color: colors.metallicGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Circular Progress Indicator Ring
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 2.8,
                        backgroundColor: colors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.isCompleted
                              ? colors.metallicGold
                              : colors.accentGreen.withValues(alpha: 0.85),
                        ),
                      ),
                      if (widget.isCompleted)
                        Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: colors.metallicGold,
                        ),
                    ],
                  ),
                ),

                const Spacer(),

                // Decrement action (subtle header control)
                if (widget.currentCount > 0)
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      size: 19,
                      color: colors.textSecondary,
                    ),
                    tooltip: 'إنقاص',
                    onPressed: widget.onDecrement,
                    visualDensity: VisualDensity.compact,
                  ),

                // Reset action (subtle header control)
                if (widget.currentCount > 0)
                  IconButton(
                    icon: Icon(
                      Icons.replay_rounded,
                      size: 19,
                      color: colors.textTertiary,
                    ),
                    tooltip: 'إعادة التعيين',
                    onPressed: widget.onReset,
                    visualDensity: VisualDensity.compact,
                  ),

                // Completed Badge
                if (widget.isCompleted)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.badgeGoldBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.badgeGoldBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: colors.metallicGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'مُكتمل',
                          style: TextStyle(
                            color: colors.metallicGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Copy Action
                IconButton(
                  icon: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: colors.textTertiary,
                  ),
                  tooltip: 'نسخ الذكر',
                  onPressed: () => _copyText(context, colors),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Main Arabic Zikr Text (Large interactive tap area)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onIncrement,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                widget.item.text,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 19 * widget.fontScale,
                  height: 1.85,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),

          // Note Section (if present)
          if (widget.item.note != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.hairline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: colors.metallicGold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.item.note!,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 6),

          // Primary Action Counter Button (Full width, Apple style, no jumping)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: widget.isCompleted
                        ? colors.elevatedSurface
                        : colors.accentGreen,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: widget.isCompleted
                        ? null
                        : [
                            BoxShadow(
                              color: colors.greenGlow.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // RTL-aware subtle progress fill inside button
                        if (!widget.isCompleted && progress > 0)
                          Positioned.fill(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                heightFactor: 1.0,
                                child: Container(
                                  color: (colors.isDark
                                          ? Colors.white
                                          : Colors.white)
                                      .withValues(alpha: 0.22),
                                ),
                              ),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.touch_app_rounded,
                              color: widget.isCompleted
                                  ? colors.accentGreen
                                  : (colors.isDark
                                      ? AppColors.pitchBlack
                                      : Colors.white),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.isCompleted
                                  ? 'تم الإنجاز (${widget.currentCount} / ${widget.item.repeatCount})'
                                  : '${widget.currentCount} / ${widget.item.repeatCount}',
                              style: TextStyle(
                                color: widget.isCompleted
                                    ? colors.textPrimary
                                    : (colors.isDark
                                        ? AppColors.pitchBlack
                                        : Colors.white),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
