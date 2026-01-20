import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/fonts.dart';
import '../../widgets/menu_items.dart';
import '../../provider/support_viewmodel.dart';
import 'contact_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'term_services_screen.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(supportMenuProvider);

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
          child: menuAsync.when(
            data: (menuItems) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 8.h,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      color: context.boxClr,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 15.h),
                        ...menuItems.map((item) {
                          return MenuItem(
                            title: item.title,
                            onTap: () {
                              if (item.id == 'contact_support') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ContactSupportScreen(),
                                  ),
                                );
                              } else if (item.id == 'privacy_policy') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PrivacyPolicyScreen(),
                                  ),
                                );
                              } else if (item.id == 'terms_of_service') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TermServicesScreen(),
                                  ),
                                );
                              } else if (item.url != null) {
                                _launchUrl(item.url!);
                              }
                            },
                          );
                        }),
                        SizedBox(height: 15.h), // Add bottom padding
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              return Center(
                child: Text(
                  'Error loading support menu',
                  style: AppFonts.m16(color: Colors.red),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $urlString');
    }
  }
}
