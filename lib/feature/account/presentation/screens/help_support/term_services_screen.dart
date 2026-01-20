import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/fonts.dart';
import '../../provider/support_viewmodel.dart';

class TermServicesScreen extends ConsumerWidget {
  const TermServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(termsOfServiceProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        title: Text(
          'Terms of Service',
          style: AppFonts.sb26(color: context.textPrimaryClr),
        ),
        centerTitle: true,
        leadingWidth: 50.h,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.pop(),
          child: Icon(
            Icons.arrow_back,
            color: context.textPrimaryClr,
            size: 32.h,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: termsAsync.when(
          data: (terms) {
            if (terms.sections.isEmpty) {
              return Center(
                child: Text(
                  'No terms of service available',
                  style: AppFonts.m16(color: context.textSecondaryClr),
                ),
              );
            }

            final scrollController = ScrollController();

            return RawScrollbar(
              controller: scrollController,
              thumbVisibility: true,
              thickness: 4.0,
              radius: const Radius.circular(8),
              thumbColor: const Color(0xFF5B4CCC).withValues(alpha: 0.7),
              trackVisibility: true,
              trackBorderColor: Colors.transparent,
              trackColor: Colors.transparent,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Effective Date
                      if (terms.effectiveDate.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: Text(
                            'Effective Date: ${terms.effectiveDate}',
                            style: AppFonts.m14(
                              color: context.textSecondaryClr,
                            ),
                          ),
                        ),

                      // Sections
                      ...terms.sections.map((section) {
                        return _buildSection(
                          context,
                          section.title,
                          section.body,
                        );
                      }),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.h, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading terms of service',
                    style: AppFonts.m16(color: Colors.red),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String body) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(title, style: AppFonts.sb18(color: context.textPrimaryClr)),
          SizedBox(height: 12.h),

          // Section Body
          Text(
            body,
            style: AppFonts.r14(color: context.textSecondaryClr),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
