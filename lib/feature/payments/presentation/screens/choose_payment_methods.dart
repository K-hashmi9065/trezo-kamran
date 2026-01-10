import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/utils/app_large_elevated_button.dart';
import '../provider/choose_payment_method_provider.dart';
import '../widgets/custom_payment_choose_card.dart';

class ChoosePaymentMethods extends ConsumerWidget {
  const ChoosePaymentMethods({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentListProvider);

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
          'Choose Payment Methods',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // List Section
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  return PaymentMethodCard(
                    payment: payments[index],
                    index: index,
                  );
                },
              ),
            ),
            // spacer
            // Spacer(),
            // OK Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppLargeElevatedButton(
                text: 'OK',
                onPressed: () {
                  //  ref.read(selectedPaymentProvider.notifier).state = index;
                  // context.push(RouteName.reviewSummary);
                },
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
