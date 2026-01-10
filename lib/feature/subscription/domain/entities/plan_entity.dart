class PlanEntity {
  final String id;
  final String planId;
  final String name;
  final String description;
  final String billingCycle; // "month" or "year"
  final double price;
  final String currencyCode;
  final List<String> features;
  final String? discountBadge; // "Save 16%" or null
  final bool isActive;
  final bool isRecommended;

  const PlanEntity({
    required this.id,
    required this.planId,
    required this.name,
    required this.description,
    required this.billingCycle,
    required this.price,
    required this.currencyCode,
    required this.features,
    this.discountBadge,
    required this.isActive,
    required this.isRecommended,
  });

  // Helper to get currency symbol from code
  String get currencySymbol {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      default:
        return currencyCode;
    }
  }

  String get displayPrice => '$currencySymbol${price.toStringAsFixed(2)}';

  String get displayPeriod => billingCycle == 'month' ? '/ month' : '/ year';

  String? get discountText => discountBadge;

  // Check if this is monthly or yearly plan
  bool get isMonthly => billingCycle == 'month';
  bool get isYearly => billingCycle == 'year';
}
