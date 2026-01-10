import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/utils/app_large_elevated_button.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';

class AddNewPayments extends ConsumerWidget {
  const AddNewPayments({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.pop(),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Image.asset(""),
          ),
        ),
        titleSpacing: 0,
        leadingWidth: 45,
        centerTitle: true,
        title: Text(
          'Add New Payment',
          style: AppFonts.b34(color: AppColors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: IconButton(
              icon: const Icon(Icons.add, size: 35),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25.h),

              // Card Number
              CustomTextField(
                label: "Card Number",
                hint: "4578 1234 5678 9123",
                controller: TextEditingController(),
              ),

              SizedBox(height: 20.h),

              // Account Holder Name
              CustomTextField(
                label: "Account Holder Name",
                hint: "Andrew Ainsley",
                controller: TextEditingController(),
              ),

              SizedBox(height: 20.h),

              // Expiry Date + CVV Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: "Expiry Date",
                      hint: "MM/YY",
                      controller: TextEditingController(),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: CustomTextField(
                      label: "CVV",
                      hint: "123",
                      controller: TextEditingController(),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 25.h),
              // devider
              Divider(color: AppColors.textDisabled),
              SizedBox(height: 28.h),
              // sponser text
              Text(
                'Supported Payments:',
                style: AppFonts.m20(color: AppColors.textSecondary),
              ),
              // 👈 pushes button to bottom
              Spacer(),
              // Save Button
              AppLargeElevatedButton(
                text: 'Save',
                onPressed: () {
                  // context.push(RouteName.connectedPayments);
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
