import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/goal.dart';

part 'goal_model.g.dart';

/// Goal data model with Hive annotations for local persistence
@HiveType(typeId: 1)
class GoalModel extends Goal {
  @HiveField(0)
  final String hiveId;

  @HiveField(1)
  final String hiveTitle;

  @HiveField(2)
  final double hiveTargetAmount;

  @HiveField(3)
  final double hiveCurrentAmount;

  @HiveField(4)
  final DateTime hiveStartDate;

  @HiveField(5)
  final DateTime? hiveTargetDate;

  @HiveField(6)
  final String hiveCategory;

  @HiveField(7)
  final String hiveCurrency;

  @HiveField(8)
  final bool hiveIsCompleted;

  @HiveField(9)
  final DateTime hiveCreatedAt;

  @HiveField(10)
  final DateTime hiveUpdatedAt;

  @HiveField(11)
  final String? hiveCoverImagePath;

  @HiveField(12)
  final String? hiveNote;

  @HiveField(13)
  final int hiveColor; // Store as int for Hive

  @HiveField(14)
  final String? hiveIcon;

  @HiveField(15)
  final bool? hiveIsArchived; // Make nullable for migration

  GoalModel({
    required this.hiveId,
    required this.hiveTitle,
    required this.hiveTargetAmount,
    required this.hiveCurrentAmount,
    required this.hiveStartDate,
    this.hiveTargetDate,
    required this.hiveCategory,
    this.hiveCurrency = 'INR',
    this.hiveIsCompleted = false,
    this.hiveIsArchived = false,
    required this.hiveCreatedAt,
    required this.hiveUpdatedAt,
    this.hiveCoverImagePath,
    this.hiveNote,
    this.hiveColor = 0xFF5B7FFF,
    this.hiveIcon,
  }) : super(
         id: hiveId,
         title: hiveTitle,
         targetAmount: hiveTargetAmount,
         currentAmount: hiveCurrentAmount,
         startDate: hiveStartDate,
         targetDate: hiveTargetDate,
         category: hiveCategory,
         currency: hiveCurrency,
         isCompleted: hiveIsCompleted,
         // Handle null when reading from Hive
         isArchived: hiveIsArchived ?? false,
         createdAt: hiveCreatedAt,
         updatedAt: hiveUpdatedAt,
         coverImagePath: hiveCoverImagePath,
         note: hiveNote,
         color: Color(hiveColor),
         icon: hiveIcon,
       );

  /// Create GoalModel from Goal entity
  factory GoalModel.fromEntity(Goal goal) {
    return GoalModel(
      hiveId: goal.id,
      hiveTitle: goal.title,
      hiveTargetAmount: goal.targetAmount,
      hiveCurrentAmount: goal.currentAmount,
      hiveStartDate: goal.startDate,
      hiveTargetDate: goal.targetDate,
      hiveCategory: goal.category,
      hiveCurrency: goal.currency,
      hiveIsCompleted: goal.isCompleted,
      hiveIsArchived: goal.isArchived,
      hiveCreatedAt: goal.createdAt,
      hiveUpdatedAt: goal.updatedAt,
      hiveCoverImagePath: goal.coverImagePath,
      hiveNote: goal.note,
      hiveColor: goal.color?.toARGB32() ?? 0xFF5B7FFF,
      hiveIcon: goal.icon,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': hiveId,
      'title': hiveTitle,
      'targetAmount': hiveTargetAmount,
      'currentAmount': hiveCurrentAmount,
      'startDate': hiveStartDate.toIso8601String(),
      'targetDate': hiveTargetDate?.toIso8601String(),
      'category': hiveCategory,
      'currency': hiveCurrency,
      'isCompleted': hiveIsCompleted,
      'isArchived': hiveIsArchived,
      'createdAt': hiveCreatedAt.toIso8601String(),
      'updatedAt': hiveUpdatedAt.toIso8601String(),
      'coverImagePath': hiveCoverImagePath,
      'note': hiveNote,
      'color': hiveColor,
      'icon': hiveIcon,
    };
  }

  /// Create from JSON
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      hiveId: json['id'] as String,
      hiveTitle: json['title'] as String,
      hiveTargetAmount: (json['targetAmount'] as num).toDouble(),
      hiveCurrentAmount: (json['currentAmount'] as num).toDouble(),
      hiveStartDate: DateTime.parse(json['startDate'] as String),
      hiveTargetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      hiveCategory: json['category'] as String,
      hiveCurrency: json['currency'] as String? ?? 'INR',
      hiveIsCompleted: json['isCompleted'] as bool? ?? false,
      hiveIsArchived: json['isArchived'] as bool? ?? false,
      hiveCreatedAt: DateTime.parse(json['createdAt'] as String),
      hiveUpdatedAt: DateTime.parse(json['updatedAt'] as String),
      hiveCoverImagePath: json['coverImagePath'] as String?,
      hiveNote: json['note'] as String?,
      hiveColor: json['color'] as int? ?? 0xFF5B7FFF,
      hiveIcon: json['icon'] as String?,
    );
  }

  /// Convert to domain entity
  Goal toEntity() {
    return Goal(
      id: hiveId,
      title: hiveTitle,
      targetAmount: hiveTargetAmount,
      currentAmount: hiveCurrentAmount,
      startDate: hiveStartDate,
      targetDate: hiveTargetDate,
      category: hiveCategory,
      currency: hiveCurrency,
      isCompleted: hiveIsCompleted,
      isArchived: hiveIsArchived ?? false,
      createdAt: hiveCreatedAt,
      updatedAt: hiveUpdatedAt,
      coverImagePath: hiveCoverImagePath,
      note: hiveNote,
      color: Color(hiveColor),
      icon: hiveIcon,
    );
  }

  /// Copy with method
  @override
  GoalModel copyWith({
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
    return GoalModel(
      hiveId: id ?? hiveId,
      hiveTitle: title ?? hiveTitle,
      hiveTargetAmount: targetAmount ?? hiveTargetAmount,
      hiveCurrentAmount: currentAmount ?? hiveCurrentAmount,
      hiveStartDate: startDate ?? hiveStartDate,
      hiveTargetDate: targetDate ?? hiveTargetDate,
      hiveCategory: category ?? hiveCategory,
      hiveCurrency: currency ?? hiveCurrency,
      hiveIsCompleted: isCompleted ?? hiveIsCompleted,
      hiveIsArchived: isArchived ?? hiveIsArchived,
      hiveCreatedAt: createdAt ?? hiveCreatedAt,
      hiveUpdatedAt: updatedAt ?? hiveUpdatedAt,
      hiveCoverImagePath: coverImagePath ?? hiveCoverImagePath,
      hiveNote: note ?? hiveNote,
      hiveColor: color?.toARGB32() ?? hiveColor,
      hiveIcon: icon ?? hiveIcon,
    );
  }
}
