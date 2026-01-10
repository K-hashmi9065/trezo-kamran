import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../provider/user_profile_viewmodel.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedImagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });

        // Upload image automatically
        if (mounted) {
          ref
              .read(userProfileViewModelProvider.notifier)
              .uploadAvatar(image.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(userProfileViewModelProvider.notifier)
          .updateProfile(
            name: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileViewModelProvider);

    // Listen to state changes and show messages
    ref.listen<UserProfileState>(userProfileViewModelProvider, (
      previous,
      next,
    ) {
      if (next is UserProfileError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      } else if (next is UserProfileSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.green),
        );
      }
    });

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        title: Text(
          'Personal Info',
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
        actions: [
          if (profileState is UserProfileLoaded)
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Save',
                style: AppFonts.m16(color: const Color(0xFF5B7FFF)),
              ),
            ),
        ],
      ),
      body: profileState is UserProfileLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState is UserProfileLoaded
          ? _buildProfileForm(profileState)
          : profileState is UserProfileError
          ? _buildErrorView(profileState.message)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildProfileForm(UserProfileLoaded state) {
    final user = state.user;

    // Initialize controllers with user data
    if (_nameController.text.isEmpty && user.displayName != null) {
      _nameController.text = user.displayName!;
    }
    if (_emailController.text.isEmpty && user.email != null) {
      _emailController.text = user.email!;
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userProfileViewModelProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 10.h),

                  // User Avatar
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60.r,
                          backgroundColor: const Color(
                            0xFF5B7FFF,
                          ).withValues(alpha: 0.1),
                          backgroundImage: _selectedImagePath != null
                              ? FileImage(File(_selectedImagePath!))
                              : user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child:
                              _selectedImagePath == null &&
                                  user.photoUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 60.r,
                                  color: const Color(0xFF5B7FFF),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: const BoxDecoration(
                              color: Color(0xFF5B7FFF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Text(
                    'Tap to change avatar',
                    style: AppFonts.m14(color: context.textSecondaryClr),
                  ),

                  SizedBox(height: 30.h),

                  // Full Name
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _nameController,
                  ),

                  // Email
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                  ),

                  // Phone Number
                  CustomTextField(
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    controller: _phoneController,
                  ),

                  SizedBox(height: 20.h),

                  // User ID (Read-only)
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: context.whiteClr,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: context.borderClr, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          color: context.textSecondaryClr,
                          size: 20.r,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User ID',
                                style: AppFonts.m14(
                                  color: context.textSecondaryClr,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                user.id,
                                style: AppFonts.m14(
                                  color: context.textPrimaryClr,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.r, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.m16(color: context.textPrimaryClr),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                ref.read(userProfileViewModelProvider.notifier).refresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B7FFF),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text('Retry', style: AppFonts.m16(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
