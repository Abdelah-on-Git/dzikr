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

  void _showResetAllDialog(
      BuildContext context, AzkarProvider provider, AppThemeColors colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تصفير جميع العدادات',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          'هل تريد إعادة ضبط جميع عدادات أذكار الصباح والمساء؟',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appleRed,
              foregroundColor: Colors.white,
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
                  content: Text(
                    'تمت إعادة ضبط جميع العدادات بنجاح',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  backgroundColor: colors.elevatedSurface,
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
        final colors = AppColors.of(context);

        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: colors.scaffoldBg,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors.accentGreen),
              ),
            ),
          );
        }

        final book = provider.book;
        if (book == null) {
          return Scaffold(
            backgroundColor: colors.scaffoldBg,
            body: Center(
              child: Text(
                'تعذر تحميل بيانات الأذكار',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: colors.scaffoldBg,
          appBar: AppBar(
            backgroundColor: colors.scaffoldBg,
            foregroundColor: colors.textPrimary,
            title: Text(
              'الخلاصة الحسناء',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  provider.isDarkMode
                      ? Icons.wb_sunny_rounded
                      : Icons.nightlight_round,
                  color: provider.isDarkMode
                      ? colors.metallicGold
                      : colors.accentGreen,
                ),
                tooltip: provider.isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  provider.toggleThemeMode();
                },
              ),
              IconButton(
                icon: const Icon(Icons.menu_book_rounded),
                tooltip: 'تنبيهات عامة',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  GeneralNotesSheet.show(context, book.generalNotes);
                },
              ),
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
                onPressed: () =>
                    _showResetAllDialog(context, provider, colors),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Header Card with App Logo and Integrated General Notes
                _buildHeroCard(
                  context,
                  book.bookTitle,
                  book.author,
                  book.generalNotes,
                  colors,
                ),

                const SizedBox(height: 24),

                // Section Title
                Text(
                  'أبواب الأذكار',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Category Boxes in Single-Column Vertical Stack (thumb-friendly layout)
                Column(
                  children: [
                    for (int i = 0; i < book.categories.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _buildCategoryCard(
                        context,
                        book.categories[i],
                        provider,
                        colors,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    String title,
    String author,
    List<String> notes,
    AppThemeColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.hairline),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Prominent App Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.badgeGoldBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: colors.metallicGoldGlow,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.5),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أذكار اليوم والليلة',
                      style: TextStyle(
                        color: colors.metallicGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'وفق السنة النبوية الصحيحة',
                      style: TextStyle(
                        color: colors.textTertiary,
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
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'تأليف: الشيخ ',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                author,
                style: TextStyle(
                  color: colors.metallicGold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Integrated General Notes inside the Top Bar / Hero Box
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                HapticFeedback.selectionClick();
                GeneralNotesSheet.show(context, notes);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.hairline),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: colors.metallicGold,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تنبيهات عامة من المصنف',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'إرشادات هامة في ترتيب الأذكار وقضائها لمن نسيها',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: colors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    AzkarCategory category,
    AzkarProvider provider,
    AppThemeColors colors,
  ) {
    final isMorning = category.categoryId == 'morning';
    final completedCount = provider.getCompletedCount(category);
    final totalCount = category.items.length;
    final progress = provider.getCategoryProgress(category);
    final isCompleted = totalCount > 0 && completedCount == totalCount;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? colors.accentGreen.withValues(alpha: 0.45)
              : colors.hairline,
          width: isCompleted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? colors.greenGlow.withValues(alpha: 0.16)
                : colors.shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: Category icon, titles, and completion badge / chevron
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isMorning
                            ? colors.badgeGoldBg
                            : (colors.isDark
                                ? const Color(0x245C6BC0)
                                : const Color(0x1A3F51B5)),
                        borderRadius: BorderRadius.circular(14),
                        border: isMorning
                            ? Border.all(color: colors.badgeGoldBorder)
                            : null,
                      ),
                      child: Icon(
                        isMorning
                            ? Icons.wb_sunny_rounded
                            : Icons.nightlight_round,
                        color: isMorning
                            ? colors.metallicGold
                            : (colors.isDark
                                ? const Color(0xFF7986CB)
                                : const Color(0xFF3F51B5)),
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
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$totalCount ذكراً مأثوراً',
                            style: TextStyle(
                              color: colors.textSecondary,
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
                          color: colors.badgeGoldBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.badgeGoldBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: colors.metallicGold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'مكتمل',
                              style: TextStyle(
                                color: colors.metallicGold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: colors.textTertiary,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Time window subtitle
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.hairline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.timeWindow,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                            height: 1.3,
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
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: isCompleted
                            ? colors.metallicGold
                            : colors.textSecondary,
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
                    minHeight: 6,
                    backgroundColor: colors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? colors.accentGreen
                          : colors.accentGreen.withValues(alpha: 0.85),
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
