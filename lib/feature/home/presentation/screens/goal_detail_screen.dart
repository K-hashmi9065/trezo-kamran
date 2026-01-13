import 'dart:math' as math;
import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/app_large_elevated_button.dart';
import '../../../../core/utils/app_tab_button.dart';
import '../../../../core/utils/app_snack_bar.dart';
import '../viewmodels/goal_viewmodel.dart';
import '../widgets/add_savings_bottom_sheet.dart';
import '../../domain/entities/goal.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Goal? _localGoal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentGoal = _localGoal ?? widget.goal;
    final progress = currentGoal.targetAmount > 0
        ? (currentGoal.currentAmount / currentGoal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        backgroundColor: context.whiteClr,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimaryClr),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.goal.title,
          style: AppFonts.sb24(color: context.textPrimaryClr),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: context.textPrimaryClr),
            onSelected: (value) async {
              if (value == 'edit') {
                // Navigate to CreateGoalScreen with the current goal for editing relative to this context
                context.push(RouteNames.createGoalScreen, extra: currentGoal);
              } else if (value == 'archive') {
                // Toggle archive status
                final updatedGoal = currentGoal.copyWith(
                  isArchived: !currentGoal.isArchived,
                  updatedAt: DateTime.now(),
                );
                await ref
                    .read(goalViewModelProvider.notifier)
                    .updateGoal(updatedGoal);

                if (context.mounted) {
                  setState(() {
                    _localGoal = updatedGoal;
                  });
                  AppSnackBar.showSuccess(
                    context,
                    message: updatedGoal.isArchived
                        ? "Goal archived"
                        : "Goal unarchived",
                    title: "Success",
                  );
                }
              } else if (value == 'delete') {
                // Confirm Delete using Bottom Sheet
                showModalBottomSheet(
                  context: context,
                  backgroundColor: context.backgroundClr,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24.r),
                    ),
                  ),
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Delete Goal',
                            style: AppFonts.sb24(color: context.textPrimaryClr),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Are you sure you want to delete this goal? This action cannot be undone.',
                            textAlign: TextAlign.center,
                            style: AppFonts.m16(
                              color: context.textSecondaryClr,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Row(
                            children: [
                              Expanded(
                                child: AppLargeElevatedButton(
                                  text: 'Cancel',
                                  backgroundColor: AppColors.lightBlue,
                                  textColor: AppColors.primaryBlue,
                                  onPressed: () {
                                    context.pop();
                                  },
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: AppLargeElevatedButton(
                                  text: 'Delete',
                                  backgroundColor: AppColors.error,
                                  textColor: AppColors.background,
                                  onPressed: () async {
                                    context.pop(); // Close bottom sheet

                                    await ref
                                        .read(goalViewModelProvider.notifier)
                                        .deleteGoal(widget.goal.id);

                                    if (context.mounted) {
                                      AppSnackBar.showSuccess(
                                        context,
                                        message: "Goal deleted successfully",
                                        title: "Deleted",
                                      );
                                      context.pop(); // Go back to goal list
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(
                        currentGoal.isArchived
                            ? Icons.unarchive
                            : Icons.archive,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(currentGoal.isArchived ? 'Unarchive' : 'Archive'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: context.whiteClr,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              height: 44.h,
              decoration: BoxDecoration(
                color: context.backgroundClr,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: AppTabButton(
                tabs: const ['Goal', 'Records'],
                selectedIndex: _tabController.index,
                onTabChanged: (index) {
                  if (index == 1) {
                    // Open records screen for this goal
                    context.push(
                      RouteNames.goalRecordsScreen,
                      extra: widget.goal,
                    );
                    return;
                  }
                  setState(() {
                    _tabController.index = index;
                  });
                },
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Goal tab
                _buildGoalTab(currentGoal, progress),

                // Records tab (placeholder)
                Center(
                  child: Text(
                    'Records coming soon',
                    style: AppFonts.r14(color: context.textSecondaryClr),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTab(Goal goal, double progress) {
    final remaining = goal.remainingAmount;
    final daysLeft = goal.daysRemaining ?? 30; // Default to 30 days
    final double dailySavings = daysLeft > 0 ? remaining / daysLeft : 0.0;
    final double weeklySavings = dailySavings * 7;
    final double monthlySavings = dailySavings * 30;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular progress indicator
          Center(
            child: SizedBox(
              width: 200.w,
              height: 200.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress circle
                  CustomPaint(
                    size: Size(200.w, 200.w),
                    painter: CircularProgressPainter(
                      progress: progress,
                      color: goal.color ?? AppColors.primaryBlue,
                      backgroundColor: context.backgroundClr,
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          color:
                              widget.goal.color?.withValues(alpha: 0.1) ??
                              AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Center(
                          child: Builder(
                            builder: (context) {
                              final cover = goal.coverImagePath;
                              if (cover != null) {
                                try {
                                  if (cover.startsWith('data:')) {
                                    final bytes = base64Decode(
                                      cover.split(',').last,
                                    );
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Image.memory(
                                        bytes,
                                        width: 60.w,
                                        height: 60.w,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }

                                  if (!kIsWeb) {
                                    final file = File(cover);
                                    if (file.existsSync()) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        child: Image.file(
                                          file,
                                          width: 60.w,
                                          height: 60.w,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }
                                  }
                                } catch (_) {
                                  // ignore and fall back to icon
                                }
                              }

                              return Text(
                                goal.icon ?? '🎯',
                                style: TextStyle(fontSize: 36.sp),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Percentage
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: AppFonts.sb32(color: context.textPrimaryClr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 32.h),

          // Savings summary
          Text('Savings', style: AppFonts.m14(color: context.textSecondaryClr)),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'Saved',
                '${goal.currency} ${_formatAmount(goal.currentAmount)}',
              ),
              _buildSummaryItem(
                'Remaining',
                '${goal.currency} ${_formatAmount(remaining)}',
              ),
              _buildSummaryItem(
                'Goal',
                '${goal.currency} ${_formatAmount(goal.targetAmount)}',
              ),
            ],
          ),

          // Deadline
          if (goal.targetDate != null) ...[
            SizedBox(height: 24.h),
            Text(
              'Deadline: ${_formatDate(goal.targetDate!)}',
              style: AppFonts.r14(color: context.textSecondaryClr),
            ),
          ],

          SizedBox(height: 32.h),

          // Savings breakdown
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: context.whiteClr,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSavingsBreakdown(
                  '${goal.currency} ${_formatAmount(dailySavings)}',
                  'Daily savings',
                ),
                _buildSavingsBreakdown(
                  '${goal.currency} ${_formatAmount(weeklySavings)}',
                  'Weekly savings',
                ),
                _buildSavingsBreakdown(
                  '${goal.currency} ${_formatAmount(monthlySavings)}',
                  'Monthly savings',
                ),
              ],
            ),
          ),

          // Note
          if (goal.note != null && goal.note!.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text('Note', style: AppFonts.m14(color: context.textSecondaryClr)),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: context.whiteClr,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                goal.note!,
                style: AppFonts.r14(color: context.textPrimaryClr),
              ),
            ),
          ],

          SizedBox(height: 32.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppLargeElevatedButton(
                  backgroundColor: AppColors.lightBlue,
                  textColor: AppColors.primaryBlue,
                  onPressed: () => _showAddSavingsSheet(isWithdraw: true),
                  text: 'Withdraw',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppLargeElevatedButton(
                  onPressed: () => _showAddSavingsSheet(isWithdraw: false),
                  text: 'Add Saving',
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppFonts.sb16(color: context.textPrimaryClr)),
        SizedBox(height: 4.h),
        Text(label, style: AppFonts.r12(color: context.textSecondaryClr)),
      ],
    );
  }

  Widget _buildSavingsBreakdown(String amount, String label) {
    return Column(
      children: [
        Text(amount, style: AppFonts.sb14(color: context.textPrimaryClr)),
        SizedBox(height: 4.h),
        Text(label, style: AppFonts.r12(color: context.textSecondaryClr)),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(2);
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Future<void> _showAddSavingsSheet({bool isWithdraw = false}) async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSavingsBottomSheet(
        currency: widget.goal.currency,
        text: isWithdraw ? 'Withdraw' : 'Add Savings',
        buttonText: isWithdraw ? 'Withdraw' : 'Add',
      ),
    );

    if (result != null) {
      final amount = result['amount'] as double? ?? 0.0;
      final note = result['note'] as String?;

      // Apply to the goal via viewmodel. Withdraw uses negative amount.
      final appliedAmount = isWithdraw ? -amount : amount;

      // Persist a transaction record for this change (this also updates the goal progress/amount on server)
      // We rely on this single source of truth to avoid double-counting.
      await ref
          .read(goalViewModelProvider.notifier)
          .addTransactionRecord(widget.goal.id, appliedAmount, note);

      // Optimistically update local UI immediately only for additions.
      // For withdraws we intentionally avoid changing the UI optimistically
      // (the persisted data / provider refresh will drive the final state).
      if (!isWithdraw) {
        final newCurrent =
            ((_localGoal ?? widget.goal).currentAmount + appliedAmount).clamp(
              0.0,
              double.infinity,
            );
        if (mounted) {
          setState(() {
            _localGoal = (_localGoal ?? widget.goal).copyWith(
              currentAmount: newCurrent,
              updatedAt: DateTime.now(),
            );
          });
        }
      }

      final noteSuffix = (note != null && note.isNotEmpty) ? ' — $note' : '';
      final action = isWithdraw ? 'withdrawn' : 'added';

      if (!mounted) return;

      // Refresh goals and update the local detail; stay on this screen
      await ref.read(goalViewModelProvider.notifier).loadGoals();

      if (!mounted) return;

      // Show success using app's toast-style snack bar
      AppSnackBar.showSuccess(
        context,
        message:
            '${widget.goal.currency}${amount.toStringAsFixed(2)} $action successfully!$noteSuffix',
        title: 'Success',
      );

      // Fetch the updated goal and apply it to the local UI (ensures withdraws also reflect)
      final updatedGoal = await ref
          .read(goalViewModelProvider.notifier)
          .getGoalById(widget.goal.id);

      if (mounted && updatedGoal != null) {
        setState(() {
          _localGoal = updatedGoal;
        });
      }
    }
  }
}

// Custom painter for circular progress
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;
    const double strokeWidth = 12.0;

    // Draw tick marks
    final tickPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const tickCount = 60; // Number of tick marks
    for (int i = 0; i < tickCount; i++) {
      final angle = (2 * math.pi / tickCount) * i;
      final isMainTick = i % 5 == 0; // Every 5th tick is longer

      final tickLength = isMainTick ? 8.0 : 4.0;
      final outerRadius = radius - strokeWidth - 2;
      final innerRadius = outerRadius - tickLength;

      final x1 = center.dx + outerRadius * math.cos(angle - math.pi / 2);
      final y1 = center.dy + outerRadius * math.sin(angle - math.pi / 2);
      final x2 = center.dx + innerRadius * math.cos(angle - math.pi / 2);
      final y2 = center.dy + innerRadius * math.sin(angle - math.pi / 2);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );
    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
