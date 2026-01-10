import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextTheme textTheme = TextTheme(
    bodyMedium: GoogleFonts.inter(fontSize: 16.sp),
    bodySmall: GoogleFonts.inter(fontSize: 14.sp),
    bodyLarge: GoogleFonts.inter(fontSize: 18.sp),
    headlineMedium: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.bold),
  );
}
