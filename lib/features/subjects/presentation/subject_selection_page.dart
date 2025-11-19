import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/subject_card.dart';
import '../../../models/subject.dart';
import '../providers/subject_selection_provider.dart';

class SubjectSelectionPage extends ConsumerStatefulWidget {
  const SubjectSelectionPage({super.key});

  @override
  ConsumerState<SubjectSelectionPage> createState() =>
      _SubjectSelectionPageState();
}

class _SubjectSelectionPageState extends ConsumerState<SubjectSelectionPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _searchQuery = '';
  Timer? _debounceTimer;
  final List<String> _searchHistory = [];
  bool _isSearchFocused = false;
  


  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  void _addToSearchHistory(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 5) {
          _searchHistory.removeLast();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use search provider with current query
    final subjectsAsync = _searchQuery.isEmpty
        ? const AsyncValue<List<Subject>>.data([])
        : ref.watch(subjectSearchProvider(_searchQuery));
    final selection = ref.watch(subjectSelectionProvider);

    return Scaffold(
      appBar: const VKUAppBar(
        title: 'Chọn môn học',
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Search bar
                SliverToBoxAdapter(
                  child: _buildModernSearchBar(),
                ),
                // Search history chips
                if (_isSearchFocused && _searchHistory.isNotEmpty && _searchQuery.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildSearchHistory(),
                  ),

                // Display selected subjects as chips
                if (selection.enrolledSubjects.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSelectedSubjectsContainer(selection),
                  ),
                // Subject list
                subjectsAsync.when(
                  data: (subjects) {
                    if (_searchQuery.isEmpty) {
                      return SliverFillRemaining(
                        child: _buildEmptySearchState(),
                      );
                    }

                    if (subjects.isEmpty) {
                      return SliverFillRemaining(
                        child: _buildNoResultsState(),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final subject = subjects[index];
                            final isEnrolled = selection.enrolledSubjects
                                .contains(subject.id);
                            final isSkipped = selection.skippedSubjects
                                .contains(subject.id);

                            return SubjectCard(
                              subject: subject,
                              index: index + 1,
                              isEnrolled: isEnrolled,
                              isSkipped: isSkipped,
                              onEnroll: () {
                                ref
                                    .read(subjectSelectionProvider.notifier)
                                    .toggleEnroll(subject.id, subject: subject);
                              },
                              onSkip: () {
                                ref
                                    .read(subjectSelectionProvider.notifier)
                                    .toggleSkip(subject.id, subject: subject);
                              },
                            );
                          },
                          childCount: subjects.length,
                        ),
                      ),
                    );
                  },
                  loading: () => SliverFillRemaining(
                    child: _buildLoadingState(),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: _buildErrorState(error.toString()),
                  ),
                ),
                // Add bottom padding for the button
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          ),
          // Bottom button (fixed at bottom)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final enrolledCount = selection.enrolledSubjects.length;
                    if (enrolledCount == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vui lòng chọn ít nhất một môn học',
                          ),
                        ),
                      );
                      return;
                    }
                    context.go('/preferences');
                  },
                  child: Text(
                    'Tiếp theo - Nhập sở thích (${selection.enrolledSubjects.length} môn)',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isSearchFocused
                ? AppTheme.vkuRed
                : Colors.grey.shade300,
            width: _isSearchFocused ? 2 : 1,
          ),
          boxShadow: _isSearchFocused
              ? [
                  BoxShadow(
                    color: AppTheme.vkuRed.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : AppTheme.subtleShadows,
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm môn học...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: _isSearchFocused ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1.0 + (value * 0.1),
                  child: Icon(
                    Icons.search,
                    color: _isSearchFocused
                        ? AppTheme.vkuRed
                        : Colors.grey.shade600,
                  ),
                );
              },
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    color: Colors.grey.shade600,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 300), () {
              setState(() {
                _searchQuery = value.trim();
              });
              if (value.trim().isNotEmpty) {
                _addToSearchHistory(value.trim());
              }
            });
          },
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addToSearchHistory(value.trim());
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchHistory() {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tìm kiếm gần đây',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((query) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = query;
                    setState(() {
                      _searchQuery = query;
                    });
                    _searchFocusNode.unfocus();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.vkuYellow50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.vkuYellow200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 14,
                          color: AppTheme.vkuYellow800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          query,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.vkuYellow900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildSelectedSubjectsContainer(SubjectSelectionState selection) {
    final enrolledSubjects = selection.getEnrolledSubjects();
    final colors = [
      AppTheme.vkuRed,
      AppTheme.vkuYellow,
      AppTheme.vkuNavy,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: AppTheme.mediumShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientRedToYellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Môn học đã chọn',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                ),
              ),
              // Count badge with pulse animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.9, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.gradientRedToYellow,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.vkuRed.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${selection.enrolledSubjects.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              // Clear all button
              if (enrolledSubjects.length > 1)
                IconButton(
                  icon: const Icon(Icons.clear_all, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xóa tất cả môn học?'),
                        content: const Text(
                          'Bạn có chắc chắn muốn xóa tất cả môn học đã chọn?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              for (final subject in enrolledSubjects) {
                                ref
                                    .read(subjectSelectionProvider.notifier)
                                    .toggleEnroll(subject.id);
                              }
                              Navigator.pop(context);
                            },
                            child: const Text('Xóa tất cả'),
                          ),
                        ],
                      ),
                    );
                  },
                  color: AppTheme.textLight,
                  tooltip: 'Xóa tất cả',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: enrolledSubjects.asMap().entries.map((entry) {
              final index = entry.key;
              final subject = entry.value;
              final color = colors[index % colors.length];
              
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color == AppTheme.vkuYellow
                            ? AppTheme.vkuYellow800
                            : color == AppTheme.vkuRed
                                ? AppTheme.vkuRed700
                                : AppTheme.vkuNavy700,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        // Could show details or navigate
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.school,
                              size: 16,
                              color: color == AppTheme.vkuYellow
                                  ? AppTheme.textDark
                                  : Colors.white,
                            ),
                            const SizedBox(width: 6),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                subject.courseName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: color == AppTheme.vkuYellow
                                      ? AppTheme.textDark
                                      : Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(subjectSelectionProvider.notifier)
                                    .toggleEnroll(subject.id);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: color == AppTheme.vkuYellow
                                      ? AppTheme.textDark.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: color == AppTheme.vkuYellow
                                      ? AppTheme.textDark
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.gradientRedToYellow,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.vkuRed.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.search,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tìm kiếm môn học',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhập tên môn học để bắt đầu tìm kiếm',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.vkuYellow50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.vkuYellow200,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.info_outline,
                size: 64,
                color: AppTheme.vkuYellow800,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Không tìm thấy kết quả',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Thử tìm kiếm với từ khóa khác hoặc điều chỉnh bộ lọc',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => _buildSkeletonCard(index),
    );
  }

  Widget _buildSkeletonCard(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.backgroundGrey,
                  Colors.white,
                  AppTheme.backgroundGrey,
                ],
                stops: [
                  0.0,
                  value,
                  1.0,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.subtleShadows,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.vkuRed50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.errorLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.error,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.gradientRedToYellow,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.subtleShadows,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    // Trigger a refresh by clearing and resetting the query
                    final currentQuery = _searchQuery;
                    _searchQuery = '';
                    Future.delayed(const Duration(milliseconds: 100), () {
                      setState(() {
                        _searchQuery = currentQuery;
                      });
                    });
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Thử lại',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
