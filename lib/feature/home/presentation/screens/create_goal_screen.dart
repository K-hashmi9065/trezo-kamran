import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/utils/app_snack_bar.dart';
import '../../../../core/utils/app_large_elevated_button.dart';
import '../../../../core/utils/app_tab_button.dart';
import '../../domain/entities/goal.dart';
import '../viewmodels/goal_viewmodel.dart';
import '../viewmodels/goal_state.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _targetDate;
  String _selectedCurrency = 'INR';
  int _selectedColor = 0xFF5B7FFF; // Default blue
  String? _selectedIcon;
  String? _selectedCoverPath; // File path when a photo is chosen as cover
  Uint8List? _selectedCoverBytes; // For web or memory-based images

  final List<String> _currencies = ['INR', 'USD', 'EUR', 'GBP', 'JPY'];

  final List<int> _colorOptions = [
    0xFF5B7FFF, // Blue
    0xFFFF9500, // Orange
    0xFF00A8E8, // Light Blue
    0xFF34C759, // Green
    0xFFFF5733, // Red/Orange
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
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

    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _createGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final goal = Goal(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      targetAmount: double.parse(_targetAmountController.text),
      currentAmount: 0,
      startDate: DateTime.now(),
      targetDate: _targetDate, // Optional now
      category: 'General', // You can make this dynamic too
      currency: _selectedCurrency,
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      coverImagePath: _selectedCoverBytes != null
          ? 'data:image/png;base64,${base64Encode(_selectedCoverBytes!)}'
          : _selectedCoverPath,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      color: Color(_selectedColor),
      icon: _selectedIcon,
    );

    final success = await ref
        .read(goalViewModelProvider.notifier)
        .createGoal(goal);
    if (!mounted) return;

    if (success) {
      // ignore: use_build_context_synchronously
      AppSnackBar.showSuccess(
        context,
        message: 'Your goal "${goal.title}" has been created!',
        title: 'Success',
      );
      if (!mounted) return;
      context.pop();
    } else {
      final state = ref.read(goalViewModelProvider);
      if (state is GoalError) {
        // ignore: use_build_context_synchronously
        AppSnackBar.showError(context, message: state.message, title: 'Error');
      }
    }
  }

  void _showAddCoverBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCoverBottomSheet(
        onIconSelected: (selection) async {
          // selection may be:
          // - a data URL (web): 'data:image/...;base64,...'
          // - a file system path (mobile)
          // - an icon emoji
          if (selection.startsWith('data:')) {
            try {
              final parts = selection.split(',');
              final bytes = base64Decode(parts.last);
              setState(() {
                _selectedCoverBytes = bytes;
                _selectedCoverPath = null;
                _selectedIcon = null;
              });
            } catch (_) {
              // treat as icon if parsing fails
              setState(() {
                _selectedIcon = selection;
                _selectedCoverBytes = null;
                _selectedCoverPath = null;
              });
            }
          } else {
            try {
              final file = File(selection);
              if (file.existsSync()) {
                setState(() {
                  _selectedCoverPath = selection;
                  _selectedCoverBytes = null;
                  _selectedIcon = null;
                });
              } else {
                setState(() {
                  _selectedIcon = selection;
                  _selectedCoverBytes = null;
                  _selectedCoverPath = null;
                });
              }
            } catch (_) {
              // Fallback to icon if any file IO error occurs
              setState(() {
                _selectedIcon = selection;
                _selectedCoverBytes = null;
                _selectedCoverPath = null;
              });
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        backgroundColor: context.whiteClr,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.textPrimaryClr),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create New Goal',
          style: AppFonts.sb26(color: context.textPrimaryClr),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add Cover
                      Center(
                        child: GestureDetector(
                          onTap: _showAddCoverBottomSheet,
                          child: Column(
                            children: [
                              Container(
                                width: 80.w,
                                height: 80.w,
                                decoration: BoxDecoration(
                                  color: AppColors.lightBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: _selectedCoverBytes != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          40.r,
                                        ),
                                        child: Image.memory(
                                          _selectedCoverBytes!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (_selectedCoverPath != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(40.r),
                                              child: Image.file(
                                                File(_selectedCoverPath!),
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : (_selectedIcon != null
                                                ? Text(
                                                    _selectedIcon!,
                                                    style: TextStyle(
                                                      fontSize: 48.sp,
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.add,
                                                    size: 32.sp,
                                                    color:
                                                        AppColors.primaryBlue,
                                                  ))),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Add Cover',
                                style: AppFonts.r12(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Goal Name
                      Text(
                        'Goal Name',
                        style: AppFonts.m14(color: context.textPrimaryClr),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Vacation, New Car, etc',
                          hintStyle: AppFonts.r14(
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: context.whiteClr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: AppColors.primaryBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a goal name';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20.h),

                      // Goal Amount
                      Text(
                        'Goal Amount',
                        style: AppFonts.m14(color: context.textPrimaryClr),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _targetAmountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: '10,000',
                          hintStyle: AppFonts.r14(
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: context.whiteClr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: AppColors.primaryBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter target amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20.h),

                      // Currency
                      Text(
                        'Currency',
                        style: AppFonts.m14(color: context.textPrimaryClr),
                      ),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: context.whiteClr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: AppColors.primaryBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                        ),
                        items: _currencies.map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Text(
                              currency,
                              style: AppFonts.r14(
                                color: context.textPrimaryClr,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCurrency = value;
                            });
                          }
                        },
                      ),

                      SizedBox(height: 20.h),

                      // Deadline (Optional)
                      Text(
                        'Deadline (Optional)',
                        style: AppFonts.m14(color: context.textPrimaryClr),
                      ),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: context.whiteClr,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.lightBlue),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _targetDate == null
                                      ? 'Set your deadline'
                                      : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                                  style: AppFonts.r14(
                                    color: _targetDate == null
                                        ? context.textSecondaryClr
                                        : context.textPrimaryClr,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.textSecondary,
                                size: 20.sp,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Note (Optional)
                      Text(
                        'Note (Optional)',
                        style: AppFonts.m14(color: context.textPrimaryClr),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add your note...',
                          hintStyle: AppFonts.r14(
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: context.whiteClr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: AppColors.lightBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: AppColors.primaryBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Color
                      Text(
                        'Color',
                        style: AppFonts.m14(color: context.textPrimaryClr),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          ..._colorOptions.map((color) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 12.w),
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: Color(color),
                                  shape: BoxShape.circle,
                                  border: _selectedColor == color
                                      ? Border.all(
                                          color: AppColors.textPrimary,
                                          width: 3,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }),
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: AppColors.primaryBlue,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: context.whiteClr,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppLargeElevatedButton(
                      onPressed: () => context.pop(),
                      text: 'Cancel',
                      backgroundColor: AppColors.lightBlue,
                      textColor: AppColors.primaryBlue,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppLargeElevatedButton(
                      onPressed: _createGoal,
                      text: 'Save',
                      backgroundColor: AppColors.primaryBlue,
                      textColor: AppColors.white,
                    ),
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

class _AddCoverBottomSheet extends StatefulWidget {
  final Function(String) onIconSelected;

  const _AddCoverBottomSheet({required this.onIconSelected});

  @override
  State<_AddCoverBottomSheet> createState() => _AddCoverBottomSheetState();
}

class _AddCoverBottomSheetState extends State<_AddCoverBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Travel & Places icons
  final List<String> _travelIcons = [
    '🏖️',
    '🎯',
    '🌍',
    '🏔️',
    '🏛️',
    '🎪',
    '✈️',
    '🚢',
    '⚓',
    '🛩️',
    '🏕️',
    '⏳',
    '🏛️',
    '👥',
    '🏞️',
    '⛩️',
    '🏰',
    '🛕',
    '🎃',
    '🕌',
    '🏖️',
    '🚁',
    '🌴',
    '🏝️',
    '🏟️',
    '🗺️',
    '🏝️',
    '🏜️',
    '🚂',
    '🏠',
    '🏬',
    '🔥',
    '🏘️',
    '🎬',
    '🏗️',
    '🏭',
    '🎡',
    '🎢',
    '🎠',
    '⛱️',
    '🚏',
    '🏨',
    '🚚',
    '🏚️',
    '🎆',
    '🏙️',
  ];

  // Activity icons
  final List<String> _activityIcons = [
    '🎯',
    '⚽',
    '🏀',
    '🎾',
    '🏐',
    '🏈',
    '⚾',
    '🎱',
    '🏓',
    '🏸',
    '🥊',
    '🎮',
    '🎲',
    '🎭',
    '🎪',
    '🎨',
    '🎬',
    '🎤',
    '🎧',
    '🎼',
    '🎹',
    '🎸',
    '🎺',
    '🎻',
  ];

  // Food icons
  final List<String> _foodIcons = [
    '🍕',
    '🍔',
    '🍟',
    '🌭',
    '🍿',
    '🧈',
    '🍖',
    '🍗',
    '🥩',
    '🥓',
    '🍤',
    '🍱',
    '🍛',
    '🍜',
    '🍝',
    '🍠',
    '🍢',
    '🍣',
    '🍦',
    '🍧',
    '🍨',
    '🍩',
    '🍪',
    '🎂',
    '🍰',
    '🧁',
    '🥧',
    '🍫',
    '🍬',
    '🍭',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 70,
      );
      if (picked == null) return;

      // Always read bytes and return a data URL, so the caller can display a preview
      final bytes = await picked.readAsBytes();
      final mime = picked.mimeType ?? 'image/png';
      final base64Str = base64Encode(bytes);
      final dataUrl = 'data:$mime;base64,$base64Str';
      widget.onIconSelected(dataUrl);
      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // close the sheet after selection
    } catch (_) {
      // silently ignore or show toast if desired
    }
  }

  Widget _buildPhotosPicker() {
    return Center(
      child: SizedBox(
        width: 200.w,
        child: AppLargeElevatedButton(
          onPressed: _pickImage,
          text: 'Pick from gallery',
          backgroundColor: AppColors.lightBlue,
          textColor: AppColors.primaryBlue,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredIcons {
    List<String> icons = [];
    if (_selectedCategory == 'All' || _selectedCategory == 'Travel & Places') {
      icons.addAll(_travelIcons);
    }
    if (_selectedCategory == 'All' || _selectedCategory == 'Activity') {
      icons.addAll(_activityIcons);
    }
    if (_selectedCategory == 'All' || _selectedCategory == 'Food') {
      icons.addAll(_foodIcons);
    }
    return icons;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: context.whiteClr,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          SizedBox(height: 16.h),

          // Title
          Text(
            'Add Cover',
            style: AppFonts.sb18(color: context.textPrimaryClr),
          ),

          SizedBox(height: 16.h),

          // Tabs
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            height: 40.h,
            decoration: BoxDecoration(
              color: context.boxClr,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: AppTabButton(
              tabs: const ['Icons', 'Photos'],
              selectedIndex: _tabController.index,
              onTabChanged: (index) {
                setState(() {
                  _tabController.index = index;
                });
              },
              textStyle: AppFonts.m14(color: AppColors.white),
            ),
          ),

          SizedBox(height: 16.h),

          // Search field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search icon',
                hintStyle: AppFonts.r14(color: context.textSecondaryClr),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
                filled: true,
                fillColor: context.boxClr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Icons & Photos tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Icons tab
                GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                  ),
                  itemCount: _filteredIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _filteredIcons[index];
                    return GestureDetector(
                      onTap: () => widget.onIconSelected(icon),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.boxClr,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Text(icon, style: TextStyle(fontSize: 28.sp)),
                        ),
                      ),
                    );
                  },
                ),

                // Photos tab
                _buildPhotosPicker(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
