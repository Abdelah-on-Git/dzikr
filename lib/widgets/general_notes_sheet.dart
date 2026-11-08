import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GeneralNotesSheet extends StatelessWidget {
  final List<String> notes;

  const GeneralNotesSheet({
    super.key,
    required this.notes,
  });

  static void show(BuildContext context, List<String> notes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => GeneralNotesSheet(notes: notes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top drag indicator pill
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF545458),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.badgeGoldBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.badgeGoldBorder),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.metallicGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'تنبيهات عامة للمصنف',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes list
            ...notes.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final note = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.badgeGoldBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.badgeGoldBorder),
                      ),
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: AppColors.metallicGold,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        note,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
