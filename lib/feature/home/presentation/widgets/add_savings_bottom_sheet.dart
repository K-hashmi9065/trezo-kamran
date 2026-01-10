import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/utils/app_large_elevated_button.dart';

class AddSavingsBottomSheet extends StatefulWidget {
  final String currency;
  final String? text;
  final String? buttonText;

  // Optional initial values for editing
  final double? initialAmount;
  final DateTime? initialDate;
  final String? initialNote;
  final bool? initialIsWithdrawal;
  final String? recordId;

  const AddSavingsBottomSheet({
    super.key,
    required this.currency,
    this.text,
    this.buttonText,
    this.initialAmount,
    this.initialDate,
    this.initialNote,
    this.initialIsWithdrawal,
    this.recordId,
  });

  @override
  State<AddSavingsBottomSheet> createState() => _AddSavingsBottomSheetState();
}

class _AddSavingsBottomSheetState extends State<AddSavingsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize fields from initial values when editing
    final widgetInit = widget.initialAmount;
    if (widgetInit != null) {
      _amountController.text = widgetInit.toStringAsFixed(2);
    }
    _selectedDate = widget.initialDate ?? DateTime.now();
    _noteController.text = widget.initialNote ?? '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleAdd() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final note = _noteController.text.trim();

      Navigator.pop(context, {
        'id': widget.recordId,
        'amount': amount,
        'date': _selectedDate,
        'note': note.isEmpty ? null : note,
        'isWithdrawal': widget.initialIsWithdrawal == true,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.whiteClr,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 24.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Center(
                child: Text(
                  widget.text ?? 'Add Savings',
                  style: AppFonts.sb20(color: context.textPrimaryClr),
                ),
              ),

              SizedBox(height: 24.h),

              // Amount Field
              Text(
                'Amount',
                style: AppFonts.m14(color: context.textPrimaryClr),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: '2,000',
                  hintStyle: AppFonts.r16(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: context.backgroundClr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
                style: AppFonts.r16(color: context.textPrimaryClr),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20.h),

              // Date Field
              Text('Date', style: AppFonts.m14(color: context.textPrimaryClr)),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.backgroundClr,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM, yyyy').format(_selectedDate),
                        style: AppFonts.r16(color: context.textPrimaryClr),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: context.textSecondaryClr,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Note Field (Optional)
              Text(
                'Note (Optional)',
                style: AppFonts.m14(color: context.textPrimaryClr),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Funds from investment',
                  hintStyle: AppFonts.r16(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: context.backgroundClr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
                style: AppFonts.r16(color: context.textPrimaryClr),
              ),

              SizedBox(height: 32.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppLargeElevatedButton(
                      backgroundColor: AppColors.lightBlue,
                      textColor: AppColors.primaryBlue,
                      onPressed: () => Navigator.pop(context),
                      text: 'Cancel',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppLargeElevatedButton(
                      onPressed: _handleAdd,
                      text: widget.buttonText ?? 'Add',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
