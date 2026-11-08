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

  static void show(BuildContext context,
      {required String bookTitle, required String author}) {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AboutSheet(bookTitle: bookTitle, author: author),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
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
                  color: colors.isDark
                      ? const Color(0xFF545458)
                      : const Color(0xFFCED4DA),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // App Logo Emblem prominently displayed
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.badgeGoldBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: colors.metallicGoldGlow.withValues(alpha: 0.35),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Book Title
            Text(
              bookTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),

            // Author
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'تأليف: الشيخ ',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 15,
                  ),
                ),
                Text(
                  author,
                  style: TextStyle(
                    color: colors.metallicGold,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.hairline),
              ),
              child: Column(
                children: [
                  Text(
                    'تطبيق مبارك يجمع أذكار الصباح والمساء وفق ما أثبته الشيخ صالح بن عبد الله العصيمي في كتابه «الخلاصة الحسناء»، ميسراً حفظها ومتابعة أعدادها وترتيبها.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: colors.hairline),
                  const SizedBox(height: 12),
                  Text(
                    'يعمل التطبيق بالكامل دون اتصال بالإنترنت',
                    style: TextStyle(
                      color: colors.textTertiary,
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
                  backgroundColor: colors.accentGreen,
                  foregroundColor:
                      colors.isDark ? AppColors.pitchBlack : Colors.white,
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
