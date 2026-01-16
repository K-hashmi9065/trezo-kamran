import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:intl/intl.dart';
import 'package:trezo_saving_ai_app/core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/entities/goal.dart';
import 'gauge_painter.dart';

class GoalGaugeWidget extends StatelessWidget {
  final Goal goal;
  final String currencyCode;

  const GoalGaugeWidget({
    super.key,
    required this.goal,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    // Progress calculation
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    // Currency formatter
    final currencyFormatter = NumberFormat.compactSimpleCurrency(
      name: currencyCode,
    );

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gauge Chart
                Flexible(
                  child: SizedBox(
                    width: 120.w,
                    height: 120.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Custom Gauge Painter
                        CustomPaint(
                          size: Size(120.w, 120.w),
                          painter: GaugePainter(
                            progress: progress,
                            progressColor: goal.color ?? AppColors.primaryBlue,
                            backgroundColor: Colors.grey.withValues(
                              alpha: 0.15,
                            ),
                            strokeWidth: 10.w,
                          ),
                        ),
                        // Center Icon
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            color: context.whiteClr,
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Center(
                            child: Builder(
                              builder: (context) {
                                final cover = goal.coverImagePath;
                                if (cover != null) {
                                  try {
                                    // Handle base64 encoded images
                                    if (cover.startsWith('data:')) {
                                      final bytes = base64Decode(
                                        cover.split(',').last,
                                      );
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          40.r,
                                        ),
                                        child: Image.memory(
                                          bytes,
                                          width: 80.w,
                                          height: 80.w,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }

                                    // Handle file path images (non-web)
                                    if (!kIsWeb) {
                                      final file = File(cover);
                                      if (file.existsSync()) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            40.r,
                                          ),
                                          child: Image.file(
                                            file,
                                            width: 80.w,
                                            height: 80.w,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (_) {
                                    // fallback to icon on error
                                  }
                                }

                                // Fallback to emoji/icon
                                return Text(
                                  goal.icon ?? '🎯',
                                  style: TextStyle(fontSize: 36.sp),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                // Current and Target Amounts
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          currencyFormatter.format(goal.currentAmount),
                          style: AppFonts.sb12(color: context.textPrimaryClr),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          currencyFormatter.format(goal.targetAmount),
                          style: AppFonts.r12(color: context.textSecondaryClr),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // Goal Title
                Text(
                  goal.title,
                  style: AppFonts.sb14(color: context.textPrimaryClr),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 2.h),

                // Target Amount (below title) - Replicated as per original logic?
                // Wait, original had: "Target Amount (below title)" and "Current and Target Amounts" above.
                // It shows target amount twice. I will keep it consistent.
                Text(
                  currencyFormatter.format(goal.targetAmount),
                  style: AppFonts.r12(color: context.textSecondaryClr),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
