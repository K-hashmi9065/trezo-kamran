import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../models/choose_payment_method_model.dart';
import '../provider/choose_payment_method_provider.dart';




class PaymentMethodCard extends ConsumerWidget {
  final PaymentMethod payment;
  final int index;

  const PaymentMethodCard({
    super.key,
    required this.payment,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedPaymentProvider);

    final bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => ref.read(selectedPaymentProvider.notifier).state = index,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.primaryBlue, width: 2)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 4),
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          children: [
            // LOGO
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(color: AppColors.background, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.credit_card, size: 40),
              ),
            ),

            const SizedBox(width: 16),

            // TEXTS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.title,
                    style: AppFonts.m18(color: AppColors.textPrimary,),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment.subtitle,
                    style: AppFonts.r16(color: AppColors.textSecondary,),
                  ),
                ],
              ),
            ),

            // CHECKMARK IF SELECTED
            if (isSelected)
              Icon(Icons.check, color: AppColors.primaryBlue, size: 26),
          ],
        ),
      ),
    );
  }
}
