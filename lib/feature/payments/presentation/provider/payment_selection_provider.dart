import 'package:flutter_riverpod/legacy.dart';

import '../../models/choose_payment_method_model.dart';


final selectedPaymentProvider = StateProvider<PaymentMethod?>((ref) {
  return null; // default empty
});
