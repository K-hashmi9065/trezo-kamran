import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/support_model.dart';
import '../../data/repositories/support_repository.dart';

final supportMenuProvider = FutureProvider<List<SupportMenuItem>>((ref) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getSupportMenuItems();
});

final contactChannelsProvider = FutureProvider<List<SupportChannel>>((
  ref,
) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getContactChannels();
});

final privacyPolicyProvider = FutureProvider<PrivacyPolicyContent>((ref) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getPrivacyPolicyContent();
});

final termsOfServiceProvider = FutureProvider<TermsOfServiceContent>((
  ref,
) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getTermsOfServiceContent();
});

final faqProvider = FutureProvider<FaqContent>((ref) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getFaqContent();
});
