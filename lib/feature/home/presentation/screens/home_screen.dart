import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../account/presentation/provider/user_profile_viewmodel.dart';
import '../../domain/entities/goal.dart';
import '../viewmodels/goal_viewmodel.dart';
import '../viewmodels/goal_state.dart';
import '../widgets/goal_gauge_widget.dart';
import '../widgets/sort_bottom_sheet.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isGaugeView = false;
  SortOption? _currentSort;
  Set<FilterOption> _currentFilters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileViewModelProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalState = ref.watch(goalViewModelProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        backgroundColor: context.whiteClr,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: InkWell(
            onTap: () {
              context.push(RouteNames.accountScreen);
            },
            child: Consumer(
              builder: (context, ref, _) {
                final userState = ref.watch(userProfileViewModelProvider);
                ImageProvider? backgroundImage;

                if (userState is UserProfileLoaded &&
                    userState.user.photoUrl != null &&
                    userState.user.photoUrl!.isNotEmpty) {
                  final url = userState.user.photoUrl!;
                  if (url.startsWith('http') || url.startsWith('https')) {
                    backgroundImage = CachedNetworkImageProvider(
                      url,
                      errorListener: (_) {
                        // Handle error or evict if needed
                      },
                    );
                  } else {
                    // Handle local file path
                    try {
                      final file = File(url);
                      if (file.existsSync()) {
                        backgroundImage = FileImage(file);
                      }
                    } catch (_) {}
                  }
                }

                return CircleAvatar(
                  backgroundColor: AppColors.lightBlue,
                  backgroundImage: backgroundImage,
                  radius: 20.r,
                  child: backgroundImage == null
                      ? Icon(
                          Icons.person,
                          color: AppColors.primaryBlue,
                          size: 22.sp,
                        )
                      : null,
                );
              },
            ),
          ),
        ),
        title: Text(
          'Trezo',
          style: AppFonts.sb26(color: context.textPrimaryClr),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isGaugeView = !_isGaugeView;
                });
              },
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: AppColors.white, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text('PRO', style: AppFonts.sb14(color: AppColors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        onPressed: () {
          context.pushNamed(RouteNames.createGoalScreen);
        },
        child: Icon(Icons.add, color: AppColors.white, size: 28.sp),
      ),
      body: Column(
        children: [
          // Goals List
          Expanded(child: _buildGoalsList(goalState)),

          // Bottom Action Bar with Sort and Filter
          Padding(
            padding: EdgeInsets.fromLTRB(95.w, 0, 95.w, 20.h),
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: context.whiteClr,
                  borderRadius: BorderRadius.circular(35.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.swap_vert,
                      label: 'Sort',
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => SortBottomSheet(
                            currentSort: _currentSort,
                            onApply: (sort) {
                              setState(() {
                                _currentSort = sort;
                              });
                            },
                          ),
                        );
                      },
                    ),
                    // Vertical Divider
                    Container(
                      height: 24.h,
                      width: 1.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      color: context.textSecondaryClr.withValues(alpha: 0.2),
                    ),
                    _buildActionButton(
                      icon: Icons.filter_list,
                      label: 'Filter',
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => FilterBottomSheet(
                            currentFilters: _currentFilters,
                            onApply: (filters) {
                              setState(() {
                                _currentFilters = filters;
                              });
                            },
                          ),
                        );
                      },
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

  Widget _buildGoalsList(GoalState state) {
    if (state is GoalLoading || state is GoalInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is GoalError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message),
          ],
        ),
      );
    }

    if (state is GoalLoaded) {
      if (state.goals.isEmpty) {
        return Center(
          child: Text(
            'No goals yet',
            style: AppFonts.r14(color: context.textSecondaryClr),
          ),
        );
      }

      var activeGoals = List<Goal>.from(state.goals);

      // Apply Filtering
      if (_currentFilters.isNotEmpty) {
        if (_currentFilters.contains(FilterOption.notStarted)) {
          // ... logic if needed, but usually filtering is exclusive or additive
        }
        // Simple filtering based on status
        final showNotStarted = _currentFilters.contains(
          FilterOption.notStarted,
        );
        final showInProgress = _currentFilters.contains(
          FilterOption.inProgress,
        );
        final showCompleted = _currentFilters.contains(FilterOption.completed);

        if (showNotStarted || showInProgress || showCompleted) {
          activeGoals = activeGoals.where((goal) {
            final isCompleted =
                goal.isCompleted ||
                (goal.targetAmount > 0 &&
                    goal.currentAmount >= goal.targetAmount);

            if (showCompleted && isCompleted) return true;
            if (showNotStarted && goal.currentAmount == 0) return true;
            if (showInProgress && goal.currentAmount > 0) return true;
            return false;
          }).toList();
        }
      }

      // Apply Sorting
      if (_currentSort != null) {
        activeGoals.sort((a, b) {
          switch (_currentSort!) {
            case SortOption.dateNewestFirst:
              return b.createdAt.compareTo(a.createdAt);
            case SortOption.dateOldestFirst:
              return a.createdAt.compareTo(b.createdAt);
            case SortOption.alphabeticalAZ:
              return a.title.compareTo(b.title);
            case SortOption.alphabeticalZA:
              return b.title.compareTo(a.title);
            case SortOption.amountLowToHigh:
              return a.targetAmount.compareTo(b.targetAmount);
            case SortOption.amountHighToLow:
              return b.targetAmount.compareTo(a.targetAmount);
            case SortOption.deadlineSoonest:
              if (a.targetDate == null) return 1;
              if (b.targetDate == null) return -1;
              return a.targetDate!.compareTo(b.targetDate!);
            case SortOption.deadlineLatest:
              if (a.targetDate == null) return 1;
              if (b.targetDate == null) return -1;
              return b.targetDate!.compareTo(a.targetDate!);
          }
        });
      }

      // Render Gauge View
      if (_isGaugeView) {
        return GridView.builder(
          padding: EdgeInsets.all(16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.75,
          ),
          itemCount: activeGoals.length,
          itemBuilder: (context, index) {
            final goal = activeGoals[index];
            return GoalGaugeWidget(goal: goal);
          },
        );
      }

      // Render Bar Chart View (Default)
      return ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: activeGoals.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final goal = activeGoals[index];
          return GoalCard(goal: goal);
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: context.textPrimaryClr, size: 24.sp),
            SizedBox(width: 6.w),
            Text(label, style: AppFonts.sb18(color: context.textPrimaryClr)),
          ],
        ),
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return InkWell(
      onTap: () {
        context.pushNamed(RouteNames.goalDetailScreen, extra: goal);
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: context.whiteClr,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Row: Icon, Title, Target Amount
            Row(
              children: [
                // Icon
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color:
                        goal.color?.withValues(alpha: 0.1) ??
                        AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        final cover = goal.coverImagePath;
                        if (cover != null) {
                          try {
                            if (cover.startsWith('data:')) {
                              final bytes = base64Decode(cover.split(',').last);
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.memory(
                                  bytes,
                                  width: 48.w,
                                  height: 48.w,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }

                            if (!kIsWeb) {
                              final file = File(cover);
                              if (file.existsSync()) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.file(
                                    file,
                                    width: 48.w,
                                    height: 48.w,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                            }
                          } catch (_) {
                            // fallback to icon
                          }
                        }

                        return Text(
                          goal.icon ??
                              '🎯', // Use goal icon or default target emoji
                          style: TextStyle(fontSize: 28.sp),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Title
                Expanded(
                  child: Text(
                    goal.title,
                    style: AppFonts.m16(color: context.textPrimaryClr),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Target Amount
                Text(
                  '${goal.currency} ${_formatAmount(goal.targetAmount)}',
                  style: AppFonts.sb16(color: context.textPrimaryClr),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Middle Row: Current Amount and Target Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.currency} ${_formatAmount(goal.currentAmount)}',
                  style: AppFonts.r14(color: context.textSecondaryClr),
                ),
                Text(
                  '${goal.currency} ${_formatAmount(goal.targetAmount)}',
                  style: AppFonts.r14(color: context.textSecondaryClr),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: context.backgroundClr,
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.color ?? AppColors.primaryBlue,
                ),
                minHeight: 6.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
