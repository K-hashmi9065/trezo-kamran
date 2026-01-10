import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/utils/app_large_elevated_button.dart';

enum SortOption {
  dateNewestFirst,
  dateOldestFirst,
  alphabeticalAZ,
  alphabeticalZA,
  amountLowToHigh,
  amountHighToLow,
  deadlineSoonest,
  deadlineLatest,
}

class SortBottomSheet extends StatefulWidget {
  final SortOption? currentSort;
  final Function(SortOption?) onApply;

  const SortBottomSheet({super.key, this.currentSort, required this.onApply});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  SortOption? _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
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
          Text('Sort by', style: AppFonts.sb18(color: context.textPrimaryClr)),

          SizedBox(height: 20.h),

          // Sort Options
          _buildSortOption(
            'Date Created (Newest First)',
            SortOption.dateNewestFirst,
          ),
          _buildSortOption(
            'Date Created (Oldest First)',
            SortOption.dateOldestFirst,
          ),
          _buildSortOption('Alphabetical (A - Z)', SortOption.alphabeticalAZ),
          _buildSortOption('Alphabetical (Z - A)', SortOption.alphabeticalZA),
          _buildSortOption(
            'Goal Amount (Low to High)',
            SortOption.amountLowToHigh,
          ),
          _buildSortOption(
            'Goal Amount (High to Low)',
            SortOption.amountHighToLow,
          ),
          _buildSortOption(
            'Deadline (Soonest to Latest)',
            SortOption.deadlineSoonest,
          ),
          _buildSortOption(
            'Deadline (Latest to Soonest)',
            SortOption.deadlineLatest,
          ),

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
                        _selectedSort = null;
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
                      widget.onApply(_selectedSort);
                      Navigator.pop(context);
                    },
                    text: "Apply",
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

  Widget _buildSortOption(String label, SortOption option) {
    final isSelected = _selectedSort == option;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSort = option;
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
