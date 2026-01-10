import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/utils/app_large_elevated_button.dart';

enum FilterOption { notStarted, inProgress, completed }

class FilterBottomSheet extends StatefulWidget {
  final Set<FilterOption> currentFilters;
  final Function(Set<FilterOption>) onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Set<FilterOption> _selectedFilters;

  @override
  void initState() {
    super.initState();
    _selectedFilters = Set.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.whiteClr,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          SizedBox(height: 20.h),

          // Title
          Text(
            'Filter by',
            style: AppFonts.sb18(color: context.textPrimaryClr),
          ),

          SizedBox(height: 20.h),

          // Filter Options
          _buildFilterOption('Not Started', FilterOption.notStarted),
          _buildFilterOption('In Progress', FilterOption.inProgress),
          _buildFilterOption('Completed', FilterOption.completed),

          SizedBox(height: 20.h),

          // Action Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                // Reset Button
                Expanded(
                  child: AppLargeElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilters.clear();
                      });
                    },
                    text: "Reset",
                    textColor: AppColors.primaryBlue,
                    backgroundColor: AppColors.lightBlue,
                  ),
                ),

                SizedBox(width: 16.w),

                // Apply Button
                Expanded(
                  child: AppLargeElevatedButton(
                    onPressed: () {
                      widget.onApply(_selectedFilters);
                      Navigator.pop(context);
                    },
                    text: 'Apply',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, FilterOption option) {
    final isSelected = _selectedFilters.contains(option);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedFilters.remove(option);
          } else {
            _selectedFilters.add(option);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppFonts.r16(color: context.textPrimaryClr)),
            if (isSelected)
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: AppColors.white, size: 16.sp),
              ),
          ],
        ),
      ),
    );
  }
}
