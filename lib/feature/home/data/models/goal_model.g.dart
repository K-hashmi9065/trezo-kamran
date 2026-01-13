// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalModelAdapter extends TypeAdapter<GoalModel> {
  @override
  final int typeId = 1;

  @override
  GoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalModel(
      hiveId: fields[0] as String,
      hiveTitle: fields[1] as String,
      hiveTargetAmount: fields[2] as double,
      hiveCurrentAmount: fields[3] as double,
      hiveStartDate: fields[4] as DateTime,
      hiveTargetDate: fields[5] as DateTime?,
      hiveCategory: fields[6] as String,
      hiveCurrency: fields[7] as String,
      hiveIsCompleted: fields[8] as bool,
      hiveIsArchived: fields[15] as bool?,
      hiveCreatedAt: fields[9] as DateTime,
      hiveUpdatedAt: fields[10] as DateTime,
      hiveCoverImagePath: fields[11] as String?,
      hiveNote: fields[12] as String?,
      hiveColor: fields[13] as int,
      hiveIcon: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GoalModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.hiveId)
      ..writeByte(1)
      ..write(obj.hiveTitle)
      ..writeByte(2)
      ..write(obj.hiveTargetAmount)
      ..writeByte(3)
      ..write(obj.hiveCurrentAmount)
      ..writeByte(4)
      ..write(obj.hiveStartDate)
      ..writeByte(5)
      ..write(obj.hiveTargetDate)
      ..writeByte(6)
      ..write(obj.hiveCategory)
      ..writeByte(7)
      ..write(obj.hiveCurrency)
      ..writeByte(8)
      ..write(obj.hiveIsCompleted)
      ..writeByte(9)
      ..write(obj.hiveCreatedAt)
      ..writeByte(10)
      ..write(obj.hiveUpdatedAt)
      ..writeByte(11)
      ..write(obj.hiveCoverImagePath)
      ..writeByte(12)
      ..write(obj.hiveNote)
      ..writeByte(13)
      ..write(obj.hiveColor)
      ..writeByte(14)
      ..write(obj.hiveIcon)
      ..writeByte(15)
      ..write(obj.hiveIsArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
