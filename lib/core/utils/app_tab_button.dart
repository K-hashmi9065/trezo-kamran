import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trezo_saving_ai_app/core/constants/app_colors.dart';
import 'package:trezo_saving_ai_app/core/constants/fonts.dart';

/// A reusable custom tab button widget for switching between multiple options
class AppTabButton extends StatelessWidget {
  /// List of tab labels to display
  final List<String> tabs;

  /// Currently selected tab index (0-based)
  final int selectedIndex;

  /// Callback when a tab is tapped, returns the tapped tab index
  final ValueChanged<int> onTabChanged;

  /// Background color for selected tab
  final Color? selectedColor;

  /// Background color for unselected tabs
  final Color? unselectedColor;

  /// Text color for selected tab
  final Color? selectedTextColor;

  /// Text color for unselected tabs
  final Color? unselectedTextColor;

  /// Text style for the tabs
  final TextStyle? textStyle;

  /// Border radius for the tab buttons
  final double? borderRadius;

  /// Height of the tab button container
  final double? height;

  const AppTabButton({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.textStyle,
    this.borderRadius,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1.h),
      child: SizedBox(
        height: 45.h,
        width: double.infinity,
        child: Row(
          children: List.generate(
            tabs.length,
            (index) => Expanded(
              child: GestureDetector(
                onTap: () => onTabChanged(index),
                child: Container(
                  height: height ?? 45.h,
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? (selectedColor ?? AppColors.primaryBlue)
                        : (unselectedColor ?? Colors.transparent),
                    borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style:
                          textStyle ??
                          AppFonts.sb18(
                            color: selectedIndex == index
                                ? (selectedTextColor ?? AppColors.white)
                                : (unselectedTextColor ??
                                      context.textPrimaryClr),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
