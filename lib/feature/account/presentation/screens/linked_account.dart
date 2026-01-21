import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../widgets/custom_linked_account.dart';
import '../provider/linked_account_viewmodel.dart';

class LinkedAccountScreen extends ConsumerWidget {
  const LinkedAccountScreen({super.key});

  // Predefined accounts with their icons
  static const List<Map<String, String>> _availableAccounts = [
    {'name': 'Google', 'logo': AppAssets.googleLogo},
    {
      'name': 'Apple',
      'logo': AppAssets.googleLogo, // Replace with actual Apple logo
    },
    {
      'name': 'Facebook',
      'logo': AppAssets.googleLogo, // Replace with actual Facebook logo
    },
    {
      'name': 'Twitter',
      'logo': AppAssets.googleLogo, // Replace with actual Twitter logo
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkedAccountsAsync = ref.watch(linkedAccountsProvider);
    final viewModel = ref.read(linkedAccountViewModelProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
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
        centerTitle: true,
        title: Text(
          'Linked Accounts',
          style: AppFonts.sb26(color: context.textPrimaryClr),
        ),
      ),
      body: SafeArea(
        child: linkedAccountsAsync.when(
          data: (linkedAccounts) {
            return ListView.builder(
              padding: EdgeInsets.only(top: 10.h),
              itemCount: _availableAccounts.length,
              itemBuilder: (context, index) {
                final account = _availableAccounts[index];
                final accountName = account['name']!;
                final accountLogo = account['logo']!;

                // Check if this account is linked
                final isLinked = linkedAccounts.any(
                  (la) =>
                      la.accountName.toLowerCase() == accountName.toLowerCase(),
                );

                // Get linked account details only if it's linked
                final linkedAccount = isLinked
                    ? linkedAccounts.firstWhere(
                        (la) =>
                            la.accountName.toLowerCase() ==
                            accountName.toLowerCase(),
                      )
                    : null;

                return LinkedAccountCard(
                  iconPath: accountLogo,
                  title: accountName,
                  username: linkedAccount?.username,
                  isConnected: isLinked,
                  onTap: () => _handleAccountTap(
                    context,
                    ref,
                    viewModel,
                    accountName,
                    accountLogo,
                    isLinked,
                  ),
                );
              },
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
                    'Error loading linked accounts',
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

  void _handleAccountTap(
    BuildContext context,
    WidgetRef ref,
    LinkedAccountViewModel viewModel,
    String accountName,
    String logo,
    bool isLinked,
  ) {
    if (isLinked) {
      // Show confirmation dialog to unlink
      _showUnlinkDialog(context, ref, viewModel, accountName);
    } else {
      // Show dialog to link account
      _showLinkDialog(context, ref, viewModel, accountName, logo);
    }
  }

  void _showUnlinkDialog(
    BuildContext context,
    WidgetRef ref,
    LinkedAccountViewModel viewModel,
    String accountName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.whiteClr,
        title: Text(
          'Unlink Account',
          style: AppFonts.sb18(color: context.textPrimaryClr),
        ),
        content: Text(
          'Are you sure you want to unlink your $accountName account?',
          style: AppFonts.r14(color: context.textSecondaryClr),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppFonts.m14(color: context.textSecondaryClr),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await viewModel.unlinkAccount(accountName.toLowerCase());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$accountName account unlinked'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to unlink account'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text('Unlink', style: AppFonts.m14(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showLinkDialog(
    BuildContext context,
    WidgetRef ref,
    LinkedAccountViewModel viewModel,
    String accountName,
    String logo,
  ) {
    final usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.whiteClr,
        title: Text(
          'Link $accountName Account',
          style: AppFonts.sb18(color: context.textPrimaryClr),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your $accountName profile URL or username:',
              style: AppFonts.r14(color: context.textSecondaryClr),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                hintText:
                    'e.g., https://${accountName.toLowerCase()}.com/username',
                hintStyle: AppFonts.r12(color: context.textDisabledClr),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
              style: AppFonts.r14(color: context.textPrimaryClr),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppFonts.m14(color: context.textSecondaryClr),
            ),
          ),
          TextButton(
            onPressed: () async {
              final username = usernameController.text.trim();
              if (username.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a username or URL'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);

              try {
                await viewModel.linkAccount(
                  accountName: accountName,
                  username: username,
                  logo: '${accountName.toLowerCase()}.png',
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$accountName account linked successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to link account: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Link',
              style: AppFonts.m14(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}
