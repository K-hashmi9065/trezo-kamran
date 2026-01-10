import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import 'transaction_remote_data_source.dart';

/// Provider for TransactionRemoteDataSource
final transactionRemoteDataSourceProvider =
    Provider<TransactionRemoteDataSource>((ref) {
      final dio = ref.watch(authenticatedDioProvider);
      return TransactionRemoteDataSource(dio);
    });
