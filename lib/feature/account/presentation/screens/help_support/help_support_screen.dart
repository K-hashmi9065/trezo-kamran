// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/fonts.dart';
import '../../widgets/menu_items.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        title: Text(
          'Help & Support',
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
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Padding(
            padding: EdgeInsets.only(left: 5.w, top: 8.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      color: context.boxClr,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 15.h),
                        MenuItem(
                          title: 'FAQ',
                          onTap: () {
                            // context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                        MenuItem(
                          title: 'Contact  & Support',
                          onTap: () {
                            // context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                        MenuItem(
                          title: 'Privacy Policy',
                          onTap: () {
                            // context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                        MenuItem(
                          title: 'Terms of Service',
                          onTap: () {
                            // context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                        MenuItem(
                          title: 'Partner',
                          onTap: () {
                            // context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                        MenuItem(
                          title: 'Job Vacancy',
                          onTap: () {
                            // context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                        MenuItem(
                          title: 'Accessibilty',
                          onTap: () {
                            // context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                        MenuItem(
                          title: 'Feedback',
                          onTap: () {
                            // context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                        MenuItem(
                          title: 'About Us',
                          onTap: () {
                            // context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                        MenuItem(
                          title: 'Rate Us',
                          onTap: () {
                            // context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                        MenuItem(
                          title: 'Visit Our Website',
                          onTap: () {
                            // context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                        MenuItem(
                          title: 'Follow us on Social Media',
                          onTap: () {
                            // context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
