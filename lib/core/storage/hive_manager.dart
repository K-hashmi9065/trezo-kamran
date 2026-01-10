import 'package:hive_flutter/hive_flutter.dart';
import '../../feature/home/data/models/goal_model.dart';
import '../../feature/home/data/models/transaction_model.dart';
import 'hive_boxes.dart';

class HiveManager {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());

    // Open boxes
    await Hive.openBox<Map<dynamic, dynamic>>(HiveBoxes.userBox);
    await Hive.openBox(HiveBoxes.savingsBox);
    await Hive.openBox<GoalModel>(HiveBoxes.goalsBox);
    await Hive.openBox<TransactionModel>(HiveBoxes.transactions);
  }

  static Box box(String name) => Hive.box(name);

  static Box<T> typedBox<T>(String name) => Hive.box<T>(name);

  static Box<GoalModel> get goalsBox => Hive.box<GoalModel>(HiveBoxes.goalsBox);

  static Box<TransactionModel> get transactionsBox =>
      Hive.box<TransactionModel>(HiveBoxes.transactions);

  static Box<Map<dynamic, dynamic>> get userBox =>
      Hive.box<Map<dynamic, dynamic>>(HiveBoxes.userBox);
}
