import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/fonts.dart';
import '../../provider/support_viewmodel.dart';
import '../../../data/models/support_model.dart';

class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  String _selectedCategory = 'General';
  String _searchQuery = '';
  final Set<String> _expandedItems = {};

  @override
  Widget build(BuildContext context) {
    final faqAsync = ref.watch(faqProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        title: Text('FAQ', style: AppFonts.sb26(color: context.textPrimaryClr)),
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
        child: faqAsync.when(
          data: (faqContent) {
            if (faqContent.items.isEmpty) {
              return Center(
                child: Text(
                  'No FAQ available',
                  style: AppFonts.m16(color: context.textSecondaryClr),
                ),
              );
            }

            // Get unique categories
            final categories = <String>[
              'General',
              'Account',
              'Services',
              'Saving',
            ];

            // Filter items based on category and search
            final filteredItems = faqContent.items.where((item) {
              final matchesCategory = item.category == _selectedCategory;
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  item.question.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  item.answer.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
              return matchesCategory && matchesSearch;
            }).toList();

            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.whiteClr,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: context.borderClr),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: AppFonts.r16(color: context.textDisabledClr),
                        prefixIcon: Icon(
                          Icons.search,
                          color: context.textDisabledClr,
                          size: 20.h,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      style: AppFonts.r16(color: context.textPrimaryClr),
                    ),
                  ),
                ),

                // Category Tabs
                SizedBox(
                  height: 50.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == _selectedCategory;

                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : context.whiteClr,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : context.borderClr,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: AppFonts.m16(
                                  color: isSelected
                                      ? Colors.white
                                      : context.textSecondaryClr,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 16.h),

                // FAQ List
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Text(
                            'No results found',
                            style: AppFonts.m16(
                              color: context.textSecondaryClr,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final isExpanded = _expandedItems.contains(item.id);

                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _buildFaqItem(context, item, isExpanded),
                            );
                          },
                        ),
                ),
              ],
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
                    'Error loading FAQ',
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

  Widget _buildFaqItem(BuildContext context, FaqItem item, bool isExpanded) {
    return Container(
      decoration: BoxDecoration(
        color: context.whiteClr,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.borderClr),
      ),
      child: Column(
        children: [
          // Question Header
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedItems.remove(item.id);
                } else {
                  _expandedItems.add(item.id);
                }
              });
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.question,
                      style: AppFonts.m18(color: context.textPrimaryClr),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: context.textSecondaryClr,
                    size: 24.h,
                  ),
                ],
              ),
            ),
          ),

          // Answer (Expandable)
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Text(
                item.answer,
                style: AppFonts.r16(color: context.textSecondaryClr),
                textAlign: TextAlign.left,
              ),
            ),
        ],
      ),
    );
  }
}
