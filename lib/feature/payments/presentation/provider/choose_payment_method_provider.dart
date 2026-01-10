import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../models/choose_payment_method_model.dart';


final selectedPaymentProvider = StateProvider<int>((ref) => 0);

final paymentListProvider = Provider<List<PaymentMethod>>((ref) {
  return [
    PaymentMethod(
      title: "PayPal",
      subtitle: "andrew.ainsley@yourdomain.com",
      icon: "assets/images/paypal.png",
    ),
    PaymentMethod(
      title: "Google Pay",
      subtitle: "andrew.ainsley@yourdomain.com",
      icon: "assets/images/google.png",
    ),
    PaymentMethod(
      title: "Apple Pay",
      subtitle: "andrew.ainsley@yourdomain.com",
      icon: "assets/images/apple.png",
    ),
    PaymentMethod(
      title: "Mastercard",
      subtitle: "•• •• •• •• 4679",
      icon: "assets/images/mastercard.png",
      isCard: true,
      lastDigits: "4679",
    ),
    PaymentMethod(
      title: "Visa",
      subtitle: "•• •• •• •• 5567",
      icon: "assets/images/visa.png",
      isCard: true,
      lastDigits: "5567",
    ),
    PaymentMethod(
      title: "American Express",
      subtitle: "•• •• •• •• 8456",
      icon: "assets/images/amex.png",
      isCard: true,
      lastDigits: "8456",
    ),
  ];
});
