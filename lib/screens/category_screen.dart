import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/azkar_category.dart';
import '../providers/azkar_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/zikr_card.dart';

class CategoryScreen extends StatefulWidget {
  final AzkarCategory category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showResetConfirmDialog(
      BuildContext context, AzkarProvider provider, AppThemeColors colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'إعادة ضبط العدادات',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          'هل تريد إعادة ضبط جميع أذكار ${widget.category.categoryName} إلى الصفر؟',
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
              provider.resetCategory(widget.category);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تمت إعادة ضبط العدادات بنجاح',
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
              'تأكيد الإعادة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showFontSizeSheet(
      BuildContext context, AzkarProvider provider, AppThemeColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                const SizedBox(height: 16),
                Text(
                  'حجم خط الأذكار',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildScaleOption(ctx, provider, 'صغير', 0.9, colors),
                    const SizedBox(width: 10),
                    _buildScaleOption(ctx, provider, 'متوسط', 1.0, colors),
                    const SizedBox(width: 10),
                    _buildScaleOption(ctx, provider, 'كبير', 1.15, colors),
                    const SizedBox(width: 10),
                    _buildScaleOption(ctx, provider, 'كبير جداً', 1.3, colors),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScaleOption(BuildContext context, AzkarProvider provider,
      String label, double scale, AppThemeColors colors) {
    final isSelected = (provider.fontScale - scale).abs() < 0.05;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          provider.changeFontScale(scale);
          HapticFeedback.selectionClick();
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colors.accentGreen : colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? colors.accentGreen : colors.hairline,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (colors.isDark ? AppColors.pitchBlack : Colors.white)
                    : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AzkarProvider>(
      builder: (context, provider, _) {
        final colors = AppColors.of(context);
        final completedCount = provider.getCompletedCount(widget.category);
        final totalCount = widget.category.items.length;
        final progress = provider.getCategoryProgress(widget.category);
        final isAllDone = totalCount > 0 && completedCount == totalCount;

        return Scaffold(
          backgroundColor: colors.scaffoldBg,
          appBar: AppBar(
            backgroundColor: colors.scaffoldBg,
            foregroundColor: colors.textPrimary,
            title: Text(
              widget.category.categoryName,
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
                icon: Icon(
                  provider.isSwipeMode
                      ? Icons.view_agenda_rounded
                      : Icons.view_carousel_rounded,
                  color: provider.isSwipeMode ? colors.metallicGold : null,
                ),
                tooltip: provider.isSwipeMode
                    ? 'عرض كقائمة'
                    : 'عرض كبطاقات متتابعة',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  provider.toggleViewMode();
                },
              ),
              IconButton(
                icon: const Icon(Icons.format_size_rounded),
                tooltip: 'حجم الخط',
                onPressed: () =>
                    _showFontSizeSheet(context, provider, colors),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'إعادة ضبط الكل',
                onPressed: () =>
                    _showResetConfirmDialog(context, provider, colors),
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: Column(
            children: [
              // Sticky Header: Time Window & Progress
              Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Time window subtitle
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.category.timeWindow,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Progress row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الإنجاز: $completedCount من $totalCount',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            color: isAllDone
                                ? colors.metallicGold
                                : colors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: colors.elevatedSurface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isAllDone
                              ? colors.accentGreen
                              : colors.accentGreen.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Celebration banner when completed
              if (isAllDone)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.badgeGoldBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.badgeGoldBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: colors.metallicGold,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'تقبل الله طاعتكم، أتممت قراءة الأذكار كاملة!',
                          style: TextStyle(
                            color: colors.metallicGold,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Zikr Cards View (List or Card-Swipe)
              Expanded(
                child: provider.isSwipeMode
                    ? _buildSwipeView(provider, colors)
                    : _buildListView(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView(AzkarProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24, top: 4),
      itemCount: widget.category.items.length,
      itemBuilder: (context, index) {
        final item = widget.category.items[index];
        final currentCount = provider.getCount(item.id);
        final isCompleted = provider.isCompleted(item);

        return ZikrCard(
          key: ValueKey(item.id),
          item: item,
          currentCount: currentCount,
          isCompleted: isCompleted,
          fontScale: provider.fontScale,
          onIncrement: () => provider.increment(item),
          onDecrement: () => provider.decrement(item),
          onReset: () => provider.resetZikr(item.id),
        );
      },
    );
  }

  Widget _buildSwipeView(AzkarProvider provider, AppThemeColors colors) {
    final total = widget.category.items.length;

    return Column(
      children: [
        // PageView takes the central card space
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: total,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.category.items[index];
              final currentCount = provider.getCount(item.id);
              final isCompleted = provider.isCompleted(item);

              return SingleChildScrollView(
                child: ZikrCard(
                  key: ValueKey(item.id),
                  item: item,
                  currentCount: currentCount,
                  isCompleted: isCompleted,
                  fontScale: provider.fontScale,
                  onIncrement: () => provider.increment(item),
                  onDecrement: () => provider.decrement(item),
                  onReset: () => provider.resetZikr(item.id),
                ),
              );
            },
          ),
        ),

        // Docked bottom controls: thumb-friendly stepper and navigation arrows
        _buildBottomNavigationControls(provider, total, colors),
      ],
    );
  }

  Widget _buildBottomNavigationControls(
      AzkarProvider provider, int total, AppThemeColors colors) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border(
          top: BorderSide(color: colors.hairline),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Stepper indicator pill at bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.badgeGoldBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.badgeGoldBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 14,
                  color: colors.metallicGold,
                ),
                const SizedBox(width: 6),
                Text(
                  'الذكر ${_currentPage + 1} من $total',
                  style: TextStyle(
                    color: colors.metallicGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Previous & Next navigation arrows docked at bottom for thumb ergonomics
          Row(
            textDirection: TextDirection.ltr,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                tooltip: 'الذكر التالي',
                color: _currentPage < total - 1
                    ? colors.textPrimary
                    : colors.textTertiary,
                onPressed: _currentPage < total - 1
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                tooltip: 'الذكر السابق',
                color: _currentPage > 0
                    ? colors.textPrimary
                    : colors.textTertiary,
                onPressed: _currentPage > 0
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
