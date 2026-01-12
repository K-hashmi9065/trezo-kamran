import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_remote_data_source.dart';

/// Provider for TransactionRemoteDataSource
final transactionRemoteDataSourceProvider =
    Provider<TransactionRemoteDataSource>((ref) {
      return TransactionRemoteDataSource(
        FirebaseFirestore.instance,
        FirebaseAuth.instance,
      );
    });
