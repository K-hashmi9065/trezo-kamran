import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../domain/entities/goal.dart';
import '../widgets/records_list.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Safely read extra passed via GoRouter or ModalRoute. It may be a Goal or a Map (LinkedMap).
    final dynamic routeExtra =
        GoRouterState.of(context).extra ??
        ModalRoute.of(context)?.settings.arguments;
    Goal? goal;
    String? titleFromMap;
    if (routeExtra is Goal) {
      goal = routeExtra;
    } else if (routeExtra is Map) {
      // If a map was passed (e.g., query parameters), try to read a title for display.
      if (routeExtra['title'] is String) {
        titleFromMap = routeExtra['title'] as String;
      }
    }

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        backgroundColor: context.backgroundClr,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimaryClr),
          onPressed: () => context.pop(),
        ),
        title: Text(
          titleFromMap ?? goal?.title ?? 'Records',
          style: AppFonts.sb24(color: context.textPrimaryClr),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: RecordsList(goal: goal),
        ),
      ),
    );
  }
}
