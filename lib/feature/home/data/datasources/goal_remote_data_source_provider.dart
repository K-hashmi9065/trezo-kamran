import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'goal_remote_data_source.dart';

/// Provider for GoalRemoteDataSource
/// Injects Firestore and FirebaseAuth instances
final goalRemoteDataSourceProvider = Provider<GoalRemoteDataSource>((ref) {
  return GoalRemoteDataSource(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});
