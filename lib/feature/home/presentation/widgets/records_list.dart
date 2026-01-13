import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/utils/app_snack_bar.dart';
import '../../../../core/utils/app_large_elevated_button.dart';
import '../widgets/add_savings_bottom_sheet.dart';
import '../viewmodels/goal_viewmodel.dart';
import '../../domain/entities/goal.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories_impl/transaction_repository_provider.dart';

class RecordItem {
  final String? id;
  final String? goalId;
  final DateTime date;
  final double signedAmount; // negative for withdrawal
  final String note;

  const RecordItem({
    this.id,
    this.goalId,
    required this.date,
    required this.signedAmount,
    required this.note,
  });

  bool get isWithdrawal => signedAmount < 0;
  double get amount => signedAmount.abs();
}

class RecordsList extends ConsumerWidget {
  final Goal? goal;
  final List<RecordItem>? records;

  const RecordsList({super.key, this.goal, this.records});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the typed transactions box
    final box = Hive.box<TransactionModel>(HiveBoxes.transactions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Records (History)',
          style: AppFonts.sb16(color: context.textPrimaryClr),
        ),
        SizedBox(height: 12.h),

        // Listen to the transactions box and rebuild when records change
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<TransactionModel> b, _) {
              // Filter transactions for the current goal and sort by date descending
              final transactionModels =
                  b.values
                      .where((t) => goal == null || t.goalId == goal!.id)
                      .toList()
                    ..sort((a, b) => b.date.compareTo(a.date));

              final parsed = transactionModels.map((t) {
                return RecordItem(
                  id: t.id,
                  goalId: t.goalId,
                  date: t.date,
                  signedAmount: t.isWithdrawal ? -t.amount : t.amount,
                  note: t.note ?? '',
                );
              }).toList();

              final items = records ?? parsed;
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'No records yet',
                    style: AppFonts.r14(color: context.textSecondaryClr),
                  ),
                );
              }

              return ListView.separated(
                itemCount: items.length,
                padding: EdgeInsets.only(bottom: 16.h),
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final r = items[index];
                  final prefix = _currencyPrefix(goal?.currency);
                  final formattedAmount = NumberFormat.decimalPattern().format(
                    r.amount,
                  );
                  final sign = r.isWithdrawal ? '-' : '+';
                  final amountText = '$sign $prefix$formattedAmount';
                  final amountColor = r.isWithdrawal
                      ? const Color(0xFFFF4D4F)
                      : const Color(0xFF34C759);

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: context.whiteClr,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        // Left: date and note
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(r.date),
                                style: AppFonts.sb18(
                                  color: context.textPrimaryClr,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                r.note,
                                style: AppFonts.m14(
                                  color: context.textSecondaryClr,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right: amount and type
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              amountText,
                              style: AppFonts.sb18(color: amountColor),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              r.isWithdrawal ? 'Withdrawals' : 'Savings',
                              style: AppFonts.m14(
                                color: context.textSecondaryClr,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 8.w),

                        // Actions menu (only for stored records with an id)
                        if (r.id != null)
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              final repo = ref.read(
                                transactionRepositoryProvider,
                              );
                              if (value == 'edit') {
                                // Open edit bottom sheet
                                final result =
                                    await showModalBottomSheet<
                                      Map<String, dynamic>?
                                    >(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          AddSavingsBottomSheet(
                                            currency: goal?.currency ?? 'INR',
                                            text: r.isWithdrawal
                                                ? 'Edit Withdraw'
                                                : 'Edit Savings',
                                            buttonText: 'Save',
                                            initialAmount: r.amount,
                                            initialDate: r.date,
                                            initialNote: r.note,
                                            initialIsWithdrawal: r.isWithdrawal,
                                            recordId: r.id,
                                          ),
                                    );

                                if (result != null) {
                                  final id = result['id']?.toString() ?? r.id!;
                                  final amount =
                                      (result['amount'] as num?)?.toDouble() ??
                                      0.0;
                                  final isWithdrawal =
                                      result['isWithdrawal'] == true;
                                  final date =
                                      result['date'] as DateTime? ?? r.date;
                                  final note = result['note'] as String? ?? '';

                                  // Update via repository
                                  await repo.updateTransaction(
                                    goalId: r.goalId ?? goal?.id ?? '',
                                    transactionId: id,
                                    amount: amount,
                                    type: isWithdrawal
                                        ? 'withdrawal'
                                        : 'deposit',
                                    date: date,
                                    note: note,
                                  );

                                  if (!context.mounted) return;

                                  // Refresh goals to update progress
                                  await ref
                                      .read(goalViewModelProvider.notifier)
                                      .loadGoals();

                                  if (!context.mounted) return;

                                  AppSnackBar.showSuccess(
                                    context,
                                    message: 'Record updated',
                                    title: 'Success',
                                  );
                                }
                              } else if (value == 'delete') {
                                final confirm = await showModalBottomSheet<bool>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => Container(
                                    decoration: BoxDecoration(
                                      color: context.whiteClr,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(24.r),
                                        topRight: Radius.circular(24.r),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(
                                      left: 24.w,
                                      right: 24.w,
                                      top: 16.h,
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom +
                                          24.h,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 40.w,
                                          height: 4.h,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Divider(color: AppColors.textDisabled),
                                        SizedBox(height: 12.h),
                                        Text(
                                          'Sure you want to delete this record?',
                                          style: AppFonts.r14(
                                            color: context.textPrimaryClr,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 20.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: AppLargeElevatedButton(
                                                backgroundColor:
                                                    AppColors.lightBlue,
                                                textColor:
                                                    AppColors.primaryBlue,
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                text: 'Cancel',
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: AppLargeElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                text: 'Yes, Delete',
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                      ],
                                    ),
                                  ),
                                );

                                if (confirm == true) {
                                  // Delete via repository
                                  await repo.deleteTransaction(
                                    r.goalId ?? goal?.id ?? '',
                                    r.id!,
                                  );

                                  if (!context.mounted) return;

                                  // Refresh goals to update progress
                                  await ref
                                      .read(goalViewModelProvider.notifier)
                                      .loadGoals();

                                  if (!context.mounted) return;

                                  AppSnackBar.showSuccess(
                                    context,
                                    message: 'Record deleted',
                                    title: 'Deleted',
                                  );
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8.w),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: Icon(
                              Icons.more_vert,
                              color: context.textSecondaryClr,
                              size: 26.sp,
                            ),
                          ),
                        if (r.id == null)
                          Icon(
                            Icons.more_vert,
                            color: context.textSecondaryClr,
                            size: 26.sp,
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return DateFormat('dd MMM, yyyy').format(d);
  }

  String _currencyPrefix(String? currency) {
    if (currency == null) return '';
    switch (currency) {
      case 'USD':
        return '\$';
      case 'INR':
        return 'INR ';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '$currency ';
    }
  }
}
