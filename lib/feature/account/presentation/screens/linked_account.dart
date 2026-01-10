import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../widgets/custom_linked_account.dart';

class LinkedAccountScreen extends ConsumerWidget {
  const LinkedAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
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
        centerTitle: true,
        title: Text(
          'Linked Accounts',
          style: AppFonts.sb26(color: context.textPrimaryClr),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // add card for connected payments
            Expanded(
              child: ListView(
                children: [
                  LinkedAccountCard(
                    iconPath: AppAssets.googleLogo,
                    title: "Google",
                    isConnected: true,
                  ),
                  LinkedAccountCard(
                    iconPath: AppAssets.googleLogo,
                    title: "Apple",
                    isConnected: true,
                  ),
                  LinkedAccountCard(
                    iconPath: AppAssets.googleLogo,
                    title: "Facebook",
                  ),
                  LinkedAccountCard(
                    iconPath: AppAssets.googleLogo,
                    title: "Twitter",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
