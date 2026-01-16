import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/fonts.dart';
import '../../widgets/menu_items.dart';
import '../../provider/support_viewmodel.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(supportMenuProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        title: Text(
          'Help & Support',
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
          child: menuAsync.when(
            data: (menuItems) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 8.h,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      color: context.boxClr,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 15.h),
                        ...menuItems.map((item) {
                          return MenuItem(
                            title: item.title,
                            onTap: () {
                              if (item.id == 'contact_support') {
                                _showContactOptions(context, ref);
                              } else if (item.url != null) {
                                _launchUrl(item.url!);
                              }
                            },
                          );
                        }),
                        SizedBox(height: 15.h), // Add bottom padding
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              return Center(
                child: Text(
                  'Error loading support menu',
                  style: AppFonts.m16(color: Colors.red),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final channelsAsync = ref.watch(contactChannelsProvider);

            return Container(
              decoration: BoxDecoration(
                color: context.boxClr,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Contact Us',
                    style: AppFonts.sb20(color: context.textPrimaryClr),
                  ),
                  SizedBox(height: 20.h),
                  channelsAsync.when(
                    data: (channels) {
                      if (channels.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(20.h),
                          child: Text(
                            "No contact channels available",
                            style: AppFonts.m16(
                              color: context.textSecondaryClr,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: channels.map((channel) {
                          return ListTile(
                            leading: _getChannelIcon(channel.id),
                            title: Text(
                              channel.title,
                              style: AppFonts.m16(
                                color: context.textPrimaryClr,
                              ),
                            ),
                            onTap: () {
                              if (channel.value != null) {
                                _launchUrl(channel.value!);
                              }
                            },
                          );
                        }).toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(
                      'Error: $e',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _getChannelIcon(String id) {
    // Return appropriate icon based on channel type/id
    // Simple basic icons for now
    switch (id.toLowerCase()) {
      case 'whatsapp':
        return const Icon(Icons.message, color: Colors.green);
      case 'email':
      case 'customer_support':
        return const Icon(Icons.email, color: Colors.blue);
      case 'phone':
        return const Icon(Icons.phone, color: Colors.blue);
      case 'facebook':
        return const Icon(Icons.facebook, color: Colors.blue);
      case 'instagram':
        return const Icon(Icons.camera_alt, color: Colors.pink); // Placeholder
      case 'twitter':
        return const Icon(Icons.alternate_email, color: Colors.lightBlue);
      case 'website':
        return const Icon(Icons.language, color: Colors.blueAccent);
      default:
        return const Icon(Icons.link, color: Colors.grey);
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
