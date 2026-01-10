import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../widgets/custom_connected_payment_card.dart';
import '../../../subscription/presentation/widgets/icon_button.dart';

class ConnectedPayments extends ConsumerWidget {
  const ConnectedPayments({super.key});

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
          'Payment Methods',
          style: AppFonts.b34(color: AppColors.textPrimary),
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
                  ConnectedPaymentCard(
                    iconPath: "",
                    title: "PayPal",
                    subtitle: "andrew.ainsley@yourdo...",
                  ),
                  ConnectedPaymentCard(
                    iconPath: "",
                    title: "Google Pay",
                    subtitle: "andrew.ainsley@yourdo...",
                  ),
                  ConnectedPaymentCard(
                    iconPath: "",
                    title: "Apple Pay",
                    subtitle: "andrew.ainsley@yourdo...",
                  ),
                  ConnectedPaymentCard(
                    iconPath: "",
                    title: "Mastercard",
                    subtitle: "•••• •••• •••• 4679",
                    isCard: true,
                  ),
                  ConnectedPaymentCard(
                    iconPath: "",
                    title: "Visa",
                    subtitle: "•••• •••• •••• 5567",
                    isCard: true,
                  ),
                ],
              ),
            ),
            // spacer
            // Spacer(),
            // OK Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconElevatedButton(
                text: 'Add New Payment',
                backgroundColor: AppColors.primaryBlue,
                assetPath: "",
                onTap: () {
                  //  ref.read(selectedPaymentProvider.notifier).state = index;
                  // context.push(RouteName.addNewPayments);
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
