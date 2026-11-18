import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/zikr_item.dart';
import '../theme/app_colors.dart';
import 'circular_counter_button.dart';
import 'islamic_corner_painter.dart';

class ZikrCard extends StatelessWidget {
  final ZikrItem item;
  final int currentCount;
  final bool isCompleted;
  final double fontScale;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;
  final bool isCarouselMode;

  const ZikrCard({
    super.key,
    required this.item,
    required this.currentCount,
    required this.isCompleted,
    required this.fontScale,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
    this.isCarouselMode = false,
  });

  void _copyText(BuildContext context, AppThemeColors colors) {
    Clipboard.setData(ClipboardData(text: item.text));
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
    final progress = (item.repeatCount > 0)
        ? (currentCount / item.repeatCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isCarouselMode ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? colors.accentGreen.withValues(alpha: 0.45)
              : colors.hairline,
          width: isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: isCompleted
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: IslamicCornerPainter(
            color: colors.metallicGold.withValues(alpha: 0.20),
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
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
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
                            item.repeatText,
                            style: TextStyle(
                              color: colors.metallicGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          isCompleted
                              ? colors.metallicGold
                              : colors.accentGreen.withValues(alpha: 0.85),
                        ),
                      ),
                      if (isCompleted)
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
                if (currentCount > 0)
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      size: 19,
                      color: colors.textSecondary,
                    ),
                    tooltip: 'إنقاص',
                    onPressed: onDecrement,
                    visualDensity: VisualDensity.compact,
                  ),

                // Reset action (subtle header control)
                if (currentCount > 0)
                  IconButton(
                    icon: Icon(
                      Icons.replay_rounded,
                      size: 19,
                      color: colors.textTertiary,
                    ),
                    tooltip: 'إعادة التعيين',
                    onPressed: onReset,
                    visualDensity: VisualDensity.compact,
                  ),

                // Completed Badge
                if (isCompleted)
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
            onTap: onIncrement,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                item.text,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: colors.textPrimary,
                  fontSize: 19 * fontScale,
                  height: 1.95,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),

          // Note Section (if present)
          if (item.note != null)
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
                      item.note!,
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

          // In List Mode: Render circular counter button centered at bottom of card
          if (!isCarouselMode) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Center(
                child: CircularCounterButton(
                  currentCount: currentCount,
                  repeatCount: item.repeatCount,
                  isCompleted: isCompleted,
                  onTap: onIncrement,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
          ],
        ],
      ),
    ),
  ),
);
  }
}
