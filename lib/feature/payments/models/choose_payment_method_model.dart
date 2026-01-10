class PaymentMethod {
  final String title;
  final String subtitle;
  final String icon;
  final bool isCard;
  final String? lastDigits;

  PaymentMethod({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isCard = false,
    this.lastDigits,
  });
}
