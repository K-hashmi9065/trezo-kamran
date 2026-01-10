import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/network/network_checker.dart';
import '../datasources/transaction_local_data_source.dart';
import '../datasources/transaction_remote_data_source_provider.dart';
import '../models/transaction_model.dart';
import 'transaction_repository.dart';

/// Provider for TransactionLocalDataSource
final transactionLocalDataSourceProvider = Provider<TransactionLocalDataSource>(
  (ref) {
    final transactionsBox = Hive.box<TransactionModel>(HiveBoxes.transactions);
    return TransactionLocalDataSource(transactionsBox);
  },
);

/// Provider for TransactionRepository
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final remoteDataSource = ref.watch(transactionRemoteDataSourceProvider);
  final localDataSource = ref.watch(transactionLocalDataSourceProvider);
  final networkChecker = ref.watch(networkCheckerProvider);

  return TransactionRepository(
    localDataSource,
    remoteDataSource,
    networkChecker,
  );
});
