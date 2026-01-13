import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../data/repositories_impl/transaction_repository_provider.dart';
import '../../domain/entities/goal.dart';
import '../widgets/records_list.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  final Object? extra;

  const RecordsScreen({super.key, this.extra});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  Goal? _goal;
  String? _titleFromMap;

  @override
  void initState() {
    super.initState();
    _parseArguments();
    // Fetch transactions if we have a goal
    if (_goal != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(transactionRepositoryProvider)
              .getGoalTransactions(_goal!.id);
        }
      });
    }
  }

  void _parseArguments() {
    final routeExtra = widget.extra;

    // Also try to read from GoRouterState if widget.extra is null,
    // strictly speaking should rely on passed arg but for backward compat:
    // We can't easily access GoRouterState in initState before context is fully ready?
    // Actually we can just rely on widget.extra which we will pass from router.

    if (routeExtra is Goal) {
      _goal = routeExtra;
    } else if (routeExtra is Map) {
      if (routeExtra['title'] is String) {
        _titleFromMap = routeExtra['title'] as String;
      }
      // Handle other map properties if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback if extra wasn't passed to constructor (e.g. legacy/direct nav?)
    // This part essentially mimics previous logic if widget.extra was null
    if (_goal == null && _titleFromMap == null) {
      final dynamic rawExtra =
          GoRouterState.of(context).extra ??
          ModalRoute.of(context)?.settings.arguments;
      if (rawExtra is Goal) {
        _goal = rawExtra;
        // Trigger fetch here if it was null before? Valid but tricky in build.
        // Ideally fetch should happen once.
        // Let's assume router passes it correctly.
      } else if (rawExtra is Map) {
        if (rawExtra['title'] is String) {
          _titleFromMap = rawExtra['title'] as String;
        }
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
          _titleFromMap ?? _goal?.title ?? 'Records',
          style: AppFonts.sb24(color: context.textPrimaryClr),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: RecordsList(goal: _goal),
        ),
      ),
    );
  }
}
