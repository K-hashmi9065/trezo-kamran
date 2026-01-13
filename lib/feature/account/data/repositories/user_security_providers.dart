import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/hive_manager.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/repositories/user_security_repository.dart';
import '../datasources/user_security_local_data_source.dart';
import '../datasources/user_security_remote_data_source.dart';
import 'user_security_repository_impl.dart';

final userSecurityRemoteDataSourceProvider =
    Provider<UserSecurityRemoteDataSource>((ref) {
      return UserSecurityRemoteDataSource(FirebaseFirestore.instance);
    });

final userSecurityLocalDataSourceProvider =
    Provider<UserSecurityLocalDataSource>((ref) {
      final box = HiveManager.userBox;
      return UserSecurityLocalDataSource(box);
    });

final userSecurityRepositoryProvider = Provider<UserSecurityRepository>((ref) {
  final remote = ref.read(userSecurityRemoteDataSourceProvider);
  final local = ref.read(userSecurityLocalDataSourceProvider);
  final networkChecker = ref.read(networkCheckerProvider);

  return UserSecurityRepositoryImpl(
    remote,
    local,
    networkChecker,
    FirebaseAuth.instance,
  );
});
