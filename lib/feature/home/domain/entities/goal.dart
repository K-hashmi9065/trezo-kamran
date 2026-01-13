import 'package:flutter/material.dart';

/// Goal entity representing a savings goal in the domain layer
class Goal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime? targetDate; // Made optional
  final String category;
  final String currency;
  final bool isCompleted;
  final bool isArchived; // New field
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverImagePath; // Optional cover image
  final String? note; // Optional note
  final Color? color; // Color value for UI
  final String? icon; // Optional icon emoji

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    this.targetDate, // Optional deadline
    required this.category,
    this.currency = 'INR',
    this.isCompleted = false,
    this.isArchived = false, // Default false
    required this.createdAt,
    required this.updatedAt,
    this.coverImagePath,
    this.note,
    this.color = const Color(0xFF5B7FFF), // Default blue color
    this.icon,
  });

  // ... (getters)

  /// Copy with method for immutability
  Goal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? startDate,
    DateTime? targetDate,
    String? category,
    String? currency,
    bool? isCompleted,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverImagePath,
    String? note,
    Color? color,
    String? icon,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      currency: currency ?? this.currency,
      isCompleted: isCompleted ?? this.isCompleted,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      note: note ?? this.note,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          targetAmount == other.targetAmount &&
          currentAmount == other.currentAmount &&
          startDate == other.startDate &&
          targetDate == other.targetDate &&
          category == other.category &&
          currency == other.currency &&
          isCompleted == other.isCompleted &&
          isArchived == other.isArchived;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      targetAmount.hashCode ^
      currentAmount.hashCode ^
      startDate.hashCode ^
      targetDate.hashCode ^
      category.hashCode ^
      currency.hashCode ^
      isCompleted.hashCode ^
      isArchived.hashCode;

  @override
  String toString() {
    return 'Goal{id: $id, title: $title, targetAmount: $targetAmount, currentAmount: $currentAmount, progress: ${progressPercentage.toStringAsFixed(1)}%, isArchived: $isArchived}';
  }

  /// Calculate progress percentage
  double get progressPercentage {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  /// Check if goal is overdue
  bool get isOverdue {
    if (targetDate == null) return false;
    return !isCompleted && DateTime.now().isAfter(targetDate!);
  }

  /// Days remaining until target date
  int? get daysRemaining {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now()).inDays;
  }

  /// Amount remaining to reach target
  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0, double.infinity);
  }
}
