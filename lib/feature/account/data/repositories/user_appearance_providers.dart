import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/storage/hive_manager.dart';
import '../../../../core/network/network_checker.dart';
import '../datasources/user_appearance_local_data_source.dart';
import '../datasources/user_appearance_remote_data_source.dart';
import '../../domain/repositories/user_appearance_repository.dart';
import '../repositories/user_appearance_repository_impl.dart';

// Data Sources

final userAppearanceRemoteDataSourceProvider =
    Provider<UserAppearanceRemoteDataSource>((ref) {
      return UserAppearanceRemoteDataSource(FirebaseFirestore.instance);
    });

final userAppearanceLocalDataSourceProvider =
    Provider<UserAppearanceLocalDataSource>((ref) {
      final box = HiveManager.userBox;
      return UserAppearanceLocalDataSource(box);
    });

// Repository

final userAppearanceRepositoryProvider = Provider<UserAppearanceRepository>((
  ref,
) {
  final remote = ref.read(userAppearanceRemoteDataSourceProvider);
  final local = ref.read(userAppearanceLocalDataSourceProvider);
  final networkChecker = ref.read(networkCheckerProvider);

  return UserAppearanceRepositoryImpl(
    remote,
    local,
    networkChecker,
    FirebaseAuth.instance,
  );
});
