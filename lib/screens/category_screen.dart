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

  void _showResetConfirmDialog(BuildContext context, AzkarProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'إعادة ضبط العدادات',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          'هل تريد إعادة ضبط جميع أذكار ${widget.category.categoryName} إلى الصفر؟',
          style: const TextStyle(
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
              provider.resetCategory(widget.category);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'تمت إعادة ضبط العدادات بنجاح',
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
              'تأكيد الإعادة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showFontSizeSheet(BuildContext context, AzkarProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
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
                      color: const Color(0xFF545458),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'حجم خط الأذكار',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildScaleOption(ctx, provider, 'صغير', 0.9),
                    const SizedBox(width: 10),
                    _buildScaleOption(ctx, provider, 'متوسط', 1.0),
                    const SizedBox(width: 10),
                    _buildScaleOption(ctx, provider, 'كبير', 1.15),
                    const SizedBox(width: 10),
                    _buildScaleOption(ctx, provider, 'كبير جداً', 1.3),
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

  Widget _buildScaleOption(
      BuildContext context, AzkarProvider provider, String label, double scale) {
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
            color: isSelected ? AppColors.pitchGreen : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.pitchGreen : AppColors.hairline,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.pitchBlack : AppColors.textPrimary,
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
        final completedCount = provider.getCompletedCount(widget.category);
        final totalCount = widget.category.items.length;
        final progress = provider.getCategoryProgress(widget.category);
        final isAllDone = totalCount > 0 && completedCount == totalCount;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.category.categoryName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  provider.isSwipeMode
                      ? Icons.view_agenda_rounded
                      : Icons.view_carousel_rounded,
                  color: provider.isSwipeMode ? AppColors.metallicGold : null,
                ),
                tooltip:
                    provider.isSwipeMode ? 'عرض كقائمة' : 'عرض كبطاقات متتابعة',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  provider.toggleViewMode();
                },
              ),
              IconButton(
                icon: const Icon(Icons.format_size_rounded),
                tooltip: 'حجم الخط',
                onPressed: () => _showFontSizeSheet(context, provider),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'إعادة ضبط الكل',
                onPressed: () => _showResetConfirmDialog(context, provider),
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: Column(
            children: [
              // Sticky Header: Time Window & Progress
              Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Time window subtitle
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.category.timeWindow,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
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
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            color: isAllDone
                                ? AppColors.pitchGreen
                                : AppColors.textSecondary,
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
                        backgroundColor: AppColors.elevatedSurface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isAllDone
                              ? AppColors.pitchGreen
                              : AppColors.pitchGreen.withValues(alpha: 0.9),
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
                    color: AppColors.badgeGreenBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.badgeGreenBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: AppColors.pitchGreen,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'تقبل الله طاعتكم، أتممت قراءة الأذكار كاملة!',
                          style: TextStyle(
                            color: AppColors.pitchGreen,
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
                    ? _buildSwipeView(provider)
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

  Widget _buildSwipeView(AzkarProvider provider) {
    final total = widget.category.items.length;

    return Column(
      children: [
        // Stepper indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.badgeGoldBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.badgeGoldBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_stories_rounded,
                      size: 13,
                      color: AppColors.metallicGold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'الذكر ${_currentPage + 1} من $total',
                      style: const TextStyle(
                        color: AppColors.metallicGold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    tooltip: 'الذكر السابق',
                    color: _currentPage > 0
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                    tooltip: 'الذكر التالي',
                    color: _currentPage < total - 1
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    onPressed: _currentPage < total - 1
                        ? () {
                            _pageController.nextPage(
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
        ),

        // PageView
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
      ],
    );
  }
}
