import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/plan_entity.dart';

class PlanModel extends PlanEntity {
  const PlanModel({
    required super.id,
    required super.planId,
    required super.name,
    required super.description,
    required super.billingCycle,
    required super.price,
    required super.currencyCode,
    required super.features,
    super.discountBadge,
    required super.isActive,
    required super.isRecommended,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String? ?? '',
      planId: json['plan_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      billingCycle: json['billing_cycle'] as String? ?? 'month',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currencyCode: json['currency_code'] as String? ?? 'USD',
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      discountBadge: json['discount_badge'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isRecommended: json['is_recommended'] as bool? ?? false,
    );
  }

  factory PlanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return PlanModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'name': name,
      'description': description,
      'billing_cycle': billingCycle,
      'price': price,
      'currency_code': currencyCode,
      'features': features,
      'discount_badge': discountBadge,
      'is_active': isActive,
      'is_recommended': isRecommended,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Firestore auto-generates IDs
    return json;
  }
}
