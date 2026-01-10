import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

/// Transaction model for goal deposits and withdrawals
@HiveType(typeId: 2)
class TransactionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String goalId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String type; // 'deposit' or 'withdrawal'

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final String? category; // Optional category for the transaction

  @HiveField(8)
  final String? paymentMethod; // e.g., 'cash', 'upi', 'bank_transfer'

  TransactionModel({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    required this.createdAt,
    this.category,
    this.paymentMethod,
  });

  /// Create from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      category: json['category'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'paymentMethod': paymentMethod,
    };
  }

  /// Copy with method
  TransactionModel copyWith({
    String? id,
    String? goalId,
    double? amount,
    String? type,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    String? category,
    String? paymentMethod,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  /// Check if this is a deposit
  bool get isDeposit => type == 'deposit';

  /// Check if this is a withdrawal
  bool get isWithdrawal => type == 'withdrawal';

  @override
  String toString() {
    return 'TransactionModel(id: $id, goalId: $goalId, amount: $amount, type: $type, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
