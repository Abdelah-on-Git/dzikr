import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/azkar_category.dart';
import '../providers/azkar_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/about_sheet.dart';
import '../widgets/general_notes_sheet.dart';
import 'category_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showResetAllDialog(BuildContext context, AzkarProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تصفير جميع العدادات',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'هل تريد إعادة ضبط جميع عدادات أذكار الصباح والمساء؟',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appleRed,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              provider.resetAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'تمت إعادة ضبط جميع العدادات بنجاح',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  backgroundColor: AppColors.elevatedSurface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text(
              'تأكيد',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AzkarProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.pitchGreen),
              ),
            ),
          );
        }

        final book = provider.book;
        if (book == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'تعذر تحميل بيانات الأذكار',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'الخلاصة الحسناء',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                tooltip: 'عن الكتاب',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  AboutSheet.show(
                    context,
                    bookTitle: book.bookTitle,
                    author: book.author,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt_rounded),
                tooltip: 'تصفير الكل',
                onPressed: () => _showResetAllDialog(context, provider),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Header Card
                _buildHeroCard(context, book.bookTitle, book.author),

                const SizedBox(height: 16),

                // General Notes Floating Card
                _buildGeneralNotesCard(context, book.generalNotes),

                const SizedBox(height: 24),

                // Section Title
                const Text(
                  'أبواب الأذكار',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Category Cards
                ...book.categories.map((cat) {
                  return _buildCategoryCard(context, cat, provider);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(BuildContext context, String title, String author) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.badgeGoldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.badgeGoldBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.metallicGoldGlow,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.metallicGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أذكار اليوم والليلة',
                      style: TextStyle(
                        color: AppColors.metallicGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'وفق السنة النبوية الصحيحة',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'تأليف: الشيخ ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                author,
                style: const TextStyle(
                  color: AppColors.metallicGold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralNotesCard(BuildContext context, List<String> notes) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        GeneralNotesSheet.show(context, notes);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.badgeGoldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.badgeGoldBorder),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.metallicGold,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تنبيهات عامة من المصنف',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'إرشادات هامة في ترتيب الأذكار وقضائها لمن نسيها',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    AzkarCategory category,
    AzkarProvider provider,
  ) {
    final isMorning = category.categoryId == 'morning';
    final completedCount = provider.getCompletedCount(category);
    final totalCount = category.items.length;
    final progress = provider.getCategoryProgress(category);
    final isCompleted = totalCount > 0 && completedCount == totalCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? AppColors.pitchGreen.withValues(alpha: 0.4)
              : AppColors.hairline,
          width: isCompleted ? 1.5 : 1,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: AppColors.pitchGreenGlow.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryScreen(category: category),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: Icon, Category Name, Completion Pill
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isMorning
                            ? AppColors.badgeGoldBg
                            : const Color(0x245C6BC0),
                        borderRadius: BorderRadius.circular(14),
                        border: isMorning
                            ? Border.all(color: AppColors.badgeGoldBorder)
                            : null,
                      ),
                      child: Icon(
                        isMorning
                            ? Icons.wb_sunny_rounded
                            : Icons.nightlight_round,
                        color: isMorning
                            ? AppColors.metallicGold
                            : const Color(0xFF7986CB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.categoryName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalCount ذكراً مأثوراً',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.badgeGoldBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.badgeGoldBorder),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.metallicGold,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'مكتمل',
                              style: TextStyle(
                                color: AppColors.metallicGold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Time window subtitle
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.timeWindow,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الإنجاز: $completedCount من $totalCount',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: isCompleted
                            ? AppColors.metallicGold
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? AppColors.pitchGreen
                          : AppColors.pitchGreen.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
