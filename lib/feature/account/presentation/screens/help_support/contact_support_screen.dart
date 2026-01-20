import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/fonts.dart';
import '../../provider/support_viewmodel.dart';

class ContactSupportScreen extends ConsumerWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(contactChannelsProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        title: Text(
          'Contact Support',
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
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: channelsAsync.when(
            data: (channels) {
              if (channels.isEmpty) {
                return Center(
                  child: Text(
                    'No contact channels available',
                    style: AppFonts.m16(color: context.textSecondaryClr),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    children: channels.map((channel) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildChannelItem(
                          context,
                          channel.title,
                          _getChannelIcon(channel.id, channel.icon),
                          () {
                            if (channel.value != null) {
                              _launchUrl(channel.value!);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              return Center(
                child: Text(
                  'Error loading contact channels',
                  style: AppFonts.m16(color: Colors.red),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChannelItem(
    BuildContext context,
    String title,
    Widget icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: context.boxClr,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
          child: Row(
            children: [
              SizedBox(width: 35.w, height: 35.h, child: icon),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.sb18(color: context.textPrimaryClr),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.textSecondaryClr,
                size: 28.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getChannelIcon(String id, [String? firebaseIcon]) {
    // Use Firebase icon if available, otherwise fall back to ID-based icon
    final iconKey = firebaseIcon?.toLowerCase() ?? id.toLowerCase();

    // Return appropriate icon based on channel type/id or Firebase icon
    switch (iconKey) {
      case 'whatsapp':
        return Icon(Icons.message, color: Colors.green, size: 28.h);
      case 'email':
      case 'customer_support':
        return Icon(Icons.email, color: Colors.blue, size: 28.h);
      case 'phone':
        return Icon(Icons.phone, color: Colors.blue, size: 28.h);
      case 'facebook':
        return Icon(Icons.facebook, color: Colors.blue, size: 28.h);
      case 'instagram':
        return Icon(Icons.camera_alt, color: Colors.pink, size: 28.h);
      case 'twitter':
      case 'x':
        return Icon(Icons.alternate_email, color: Colors.lightBlue, size: 28.h);
      case 'website':
        return Icon(Icons.language, color: Colors.blueAccent, size: 28.h);
      default:
        return Icon(Icons.language_rounded, color: Colors.grey, size: 28.h);
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $urlString');
    }
  }
}
