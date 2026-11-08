import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AboutSheet extends StatelessWidget {
  final String bookTitle;
  final String author;

  const AboutSheet({
    super.key,
    required this.bookTitle,
    required this.author,
  });

  static void show(BuildContext context, {required String bookTitle, required String author}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AboutSheet(bookTitle: bookTitle, author: author),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
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
            const SizedBox(height: 20),

            // Icon / Emblem
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.badgeGreenBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.badgeGreenBorder),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pitchGreenGlow.withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.pitchGreen,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Book Title
            Text(
              bookTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),

            // Author
            Text(
              'تأليف: الشيخ $author',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.pitchGreen,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.hairline),
              ),
              child: const Column(
                children: [
                  Text(
                    'تطبيق مبارك يجمع أذكار الصباح والمساء وفق ما أثبته الشيخ صالح بن عبد الله العصيمي في كتابه «الخلاصة الحسناء»، ميسراً حفظها ومتابعة أعدادها وترتيبها.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 12),
                  Text(
                    'يعمل التطبيق بالكامل دون اتصال بالإنترنت',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Close CTA
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pitchGreen,
                  foregroundColor: AppColors.pitchBlack,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
