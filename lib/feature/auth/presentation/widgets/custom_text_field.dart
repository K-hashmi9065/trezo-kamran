import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.sb18(color: context.textPrimaryClr)),
        SizedBox(height: 8.h), // responsive spacing
        TextField(
          controller: controller,
          obscureText: obscure,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          style: AppFonts.sb17(color: context.textPrimaryClr),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.sb17(color: context.textSecondaryClr),

            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,

            isDense: true,
            filled: true,
            fillColor: context.boxClr,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 16.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }
}
