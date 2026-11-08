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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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

  void _copyText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.item.text));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم نسخ الذكر إلى الحافظة',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.elevatedSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.item.repeatCount > 0)
        ? (widget.currentCount / widget.item.repeatCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isCompleted
              ? AppColors.pitchGreen.withOpacity(0.45)
              : AppColors.hairline,
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: widget.isCompleted
            ? [
                BoxShadow(
                  color: AppColors.pitchGreenGlow.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info: Repeat text pill + Completed status badge + copy button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                // Repetition Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.repeat_rounded,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.item.repeatText,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Completed Badge
                if (widget.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.badgeGreenBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.badgeGreenBorder),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.pitchGreen,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'مُكتمل',
                          style: TextStyle(
                            color: AppColors.pitchGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 4),
                // Copy Action
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                  tooltip: 'نسخ الذكر',
                  onPressed: () => _copyText(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Main Arabic Zikr Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Text(
              widget.item.text,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19 * widget.fontScale,
                height: 1.85,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
              ),
            ),
          ),

          // Note Section (if present)
          if (widget.item.note != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.appleOrange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.item.note!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Interactive Tap Area & Action Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(
              children: [
                // Main Interactive Counter Button
                Expanded(
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
                              ? AppColors.elevatedSurface
                              : AppColors.pitchGreen,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: widget.isCompleted
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppColors.pitchGreen.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Subtle progress fill inside button
                            if (!widget.isCompleted && progress > 0)
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                width: (MediaQuery.of(context).size.width - 120) *
                                    progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(16),
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
                                      ? AppColors.pitchGreen
                                      : AppColors.pitchBlack,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.isCompleted
                                      ? 'تم الإنجاز (${widget.currentCount} / ${widget.item.repeatCount})'
                                      : '${widget.currentCount} / ${widget.item.repeatCount}',
                                  style: TextStyle(
                                    color: widget.isCompleted
                                        ? AppColors.textPrimary
                                        : AppColors.pitchBlack,
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

                const SizedBox(width: 10),

                // Decrement button
                if (widget.currentCount > 0)
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.remove_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      tooltip: 'إنقاص',
                      onPressed: widget.onDecrement,
                    ),
                  ),

                if (widget.currentCount > 0) const SizedBox(width: 8),

                // Reset button
                if (widget.currentCount > 0)
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.replay_rounded,
                        color: AppColors.textTertiary,
                        size: 19,
                      ),
                      tooltip: 'إعادة التعيين',
                      onPressed: widget.onReset,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
