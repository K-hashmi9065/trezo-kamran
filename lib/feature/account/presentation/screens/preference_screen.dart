import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trezo_saving_ai_app/feature/account/presentation/widgets/settings_tile.dart'
    show SettingsTile;

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../provider/user_appearance_viewmodel.dart';

class PreferenceScreen extends ConsumerWidget {
  const PreferenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        title: Text(
          'Preferences',
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
          child: Padding(
            padding: EdgeInsets.only(left: 5.w, top: 8.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      color: context.boxClr,
                    ),
                    child: Column(
                      children: [
                        Builder(
                          builder: (context) {
                            final savingsView = ref
                                .watch(userAppearanceViewModelProvider)
                                .savingsView;
                            return SettingsTile(
                              title: "Savings Goal View",
                              rowSubtitle: savingsView == 'bar_chart'
                                  ? "Bar Chart"
                                  : "Gauge Chart",
                              onTap: () {
                                final RenderBox box =
                                    context.findRenderObject() as RenderBox;
                                final Offset position = box.localToGlobal(
                                  Offset.zero,
                                );
                                showMenu<String>(
                                  context: context,
                                  color: context.boxClr,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  position: RelativeRect.fromLTRB(
                                    position.dx + box.size.width - 150.w,
                                    position.dy + box.size.height - 10.h,
                                    position.dx + box.size.width,
                                    position.dy + box.size.height,
                                  ),
                                  items: [
                                    PopupMenuItem(
                                      value: 'bar_chart',
                                      child: Text(
                                        'Bar Chart',
                                        style: AppFonts.m16(
                                          color: context.textPrimaryClr,
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'gauge_chart',
                                      child: Text(
                                        'Gauge Chart',
                                        style: AppFonts.m16(
                                          color: context.textPrimaryClr,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).then((value) {
                                  if (value != null) {
                                    ref
                                        .read(
                                          userAppearanceViewModelProvider
                                              .notifier,
                                        )
                                        .updateSavingsView(value);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      color: context.boxClr,
                    ),
                    child: Column(
                      children: [
                        Builder(
                          builder: (context) {
                            final currencyCode = ref
                                .watch(userAppearanceViewModelProvider)
                                .currency;

                            // Format currency to show symbol and code (e.g. "$ USD") or descriptive
                            final format = NumberFormat.simpleCurrency(
                              name: currencyCode,
                            );
                            final displayString =
                                "${format.currencySymbol} $currencyCode";

                            return SettingsTile(
                              title: "Default Currency",
                              rowSubtitle: displayString,
                              onTap: () {
                                showCurrencyPicker(
                                  context: context,
                                  showFlag: true,
                                  showCurrencyName: true,
                                  showCurrencyCode: true,
                                  onSelect: (Currency value) {
                                    ref
                                        .read(
                                          userAppearanceViewModelProvider
                                              .notifier,
                                        )
                                        .updateCurrency(value.code);
                                  },
                                  theme: CurrencyPickerThemeData(
                                    backgroundColor: context.boxClr,
                                    titleTextStyle: AppFonts.sb18(
                                      color: context.textPrimaryClr,
                                    ),
                                    subtitleTextStyle: AppFonts.m14(
                                      color: context.textSecondaryClr,
                                    ),
                                    currencySignTextStyle: AppFonts.m18(
                                      color: context.textPrimaryClr,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        Builder(
                          builder: (context) {
                            final firstDayOfWeek = ref
                                .watch(userAppearanceViewModelProvider)
                                .firstDayOfWeek;
                            return SettingsTile(
                              title: "First Day of Week",
                              rowSubtitle: firstDayOfWeek,
                              onTap: () {
                                final RenderBox box =
                                    context.findRenderObject() as RenderBox;
                                final Offset position = box.localToGlobal(
                                  Offset.zero,
                                );
                                final days = [
                                  'Sunday',
                                  'Monday',
                                  'Tuesday',
                                  'Wednesday',
                                  'Thursday',
                                  'Friday',
                                  'Saturday',
                                ];
                                showMenu<String>(
                                  context: context,
                                  color: context.boxClr,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  position: RelativeRect.fromLTRB(
                                    position.dx + box.size.width - 150.w,
                                    position.dy + box.size.height - 10.h,
                                    position.dx + box.size.width,
                                    position.dy + box.size.height,
                                  ),
                                  items: days
                                      .map(
                                        (day) => PopupMenuItem(
                                          value: day,
                                          child: Text(
                                            day,
                                            style: AppFonts.m16(
                                              color: context.textPrimaryClr,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ).then((value) {
                                  if (value != null) {
                                    ref
                                        .read(
                                          userAppearanceViewModelProvider
                                              .notifier,
                                        )
                                        .updateFirstDayOfWeek(value);
                                  }
                                });
                              },
                            );
                          },
                        ),
                        Builder(
                          builder: (context) {
                            final dateFormat = ref
                                .watch(userAppearanceViewModelProvider)
                                .dateFormat;
                            return SettingsTile(
                              title: "Date Format",
                              rowSubtitle: dateFormat,
                              onTap: () {
                                final RenderBox box =
                                    context.findRenderObject() as RenderBox;
                                final Offset position = box.localToGlobal(
                                  Offset.zero,
                                );
                                final formats = [
                                  'System Default',
                                  'DD/MM/YYYY',
                                  'MM/DD/YYYY',
                                  'YYYY-MM-DD',
                                ];
                                showMenu<String>(
                                  context: context,
                                  color: context.boxClr,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  position: RelativeRect.fromLTRB(
                                    position.dx + box.size.width - 150.w,
                                    position.dy + box.size.height - 10.h,
                                    position.dx + box.size.width,
                                    position.dy + box.size.height,
                                  ),
                                  items: formats
                                      .map(
                                        (format) => PopupMenuItem(
                                          value: format,
                                          child: Text(
                                            format,
                                            style: AppFonts.m16(
                                              color: context.textPrimaryClr,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ).then((value) {
                                  if (value != null) {
                                    ref
                                        .read(
                                          userAppearanceViewModelProvider
                                              .notifier,
                                        )
                                        .updateDateFormat(value);
                                  }
                                });
                              },
                            );
                          },
                        ),
                        SizedBox(height: 5.h),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      color: context.boxClr,
                    ),
                    child: Column(children: [const _CacheSettingsTile()]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CacheSettingsTile extends ConsumerStatefulWidget {
  const _CacheSettingsTile();

  @override
  ConsumerState<_CacheSettingsTile> createState() => _CacheSettingsTileState();
}

class _CacheSettingsTileState extends ConsumerState<_CacheSettingsTile> {
  String _cacheSize = "Calculating...";

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();
  }

  Future<void> _calculateCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempSize = _getDirSize(tempDir);

      // Optionally calculate other cache dirs if needed, but temp is safest to clear

      setState(() {
        _cacheSize = _formatSize(tempSize);
      });
    } catch (e) {
      setState(() {
        _cacheSize = "Unknown";
      });
    }
  }

  int _getDirSize(Directory dir) {
    int size = 0;
    try {
      if (dir.existsSync()) {
        dir.listSync(recursive: true, followLinks: false).forEach((
          FileSystemEntity entity,
        ) {
          if (entity is File) {
            size += entity.lengthSync();
          }
        });
      }
    } catch (e) {
      // ignore access errors
    }
    return size;
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  Future<void> _clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }

      // Also clear image cache
      if (mounted) {
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      }

      await ref
          .read(userAppearanceViewModelProvider.notifier)
          .updateLastCacheCleared();

      await _calculateCacheSize();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Cache cleared successfully",
              style: AppFonts.m14(color: Colors.white),
            ),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to clear cache",
              style: AppFonts.m14(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: "Clear Cache",
      rowSubtitle: _cacheSize,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: context.boxClr,
            title: Text(
              "Clear Cache",
              style: AppFonts.sb18(color: context.textPrimaryClr),
            ),
            content: Text(
              "Are you sure you want to clear the app cache? This will free up space but may slow down reloading some images.",
              style: AppFonts.m14(color: context.textPrimaryClr),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  "Cancel",
                  style: AppFonts.sb14(color: context.textSecondaryClr),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.pop();
                  _clearCache();
                },
                child: Text("Clear", style: AppFonts.sb14(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }
}
