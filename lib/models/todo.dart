import 'package:hive/hive.dart';
import 'dart:typed_data';

part 'todo.g.dart';

@HiveType(typeId: 0)
enum Status {
  @HiveField(0)
  pending,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  completed,
}

extension StatusX on Status {
  String labelWithOptionalCount(int count) {
    return count > 3 ? '$label ($count)' : label;
  }

  Status? get next {
    switch (this) {
      case Status.pending:
        return Status.inProgress;

      case Status.inProgress:
        return Status.completed;

      case Status.completed:
        return null; // nothing after completed
    }
  }

  String get label {
    switch (this) {
      case Status.pending:
        return 'Pending';
      case Status.inProgress:
        return 'In Progress';
      case Status.completed:
        return 'Completed';
    }
  }
}

@HiveType(typeId: 1)
class Todo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  Status status;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  RepeatFrequency repeat;

  @HiveField(7)
  DateTime? repeatEndDate;

  @HiveField(8)
  DateTime? completedOn;

  @HiveField(9)
  Uint8List? imageBytes;

  @HiveField(10)
  DateTime? dueDate;

  @HiveField(11)
  String? imagePath;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.repeat = RepeatFrequency.none,
    this.repeatEndDate,
    this.completedOn,
    this.dueDate,
    this.imagePath,
    this.imageBytes,
  });
}

@HiveType(typeId: 2)
enum RepeatFrequency {
  @HiveField(0)
  none,

  @HiveField(1)
  daily,

  @HiveField(2)
  weekly,

  @HiveField(3)
  monthly,

  @HiveField(4)
  yearly,
}

extension RepeatFrequencyX on RepeatFrequency {
  String get label {
    switch (this) {
      case RepeatFrequency.none:
        return 'None';
      case RepeatFrequency.daily:
        return 'Daily';
      case RepeatFrequency.weekly:
        return 'Weekly';
      case RepeatFrequency.monthly:
        return 'Monthly';
      case RepeatFrequency.yearly:
        return 'Yearly';
    }
  }

  DateTime calculateNext(DateTime base) {
    final dateOnly = DateTime(base.year, base.month, base.day);
    switch (this) {
      case RepeatFrequency.daily:
        return dateOnly.add(const Duration(days: 1));
      case RepeatFrequency.weekly:
        return dateOnly.add(const Duration(days: 7));
      case RepeatFrequency.monthly:
        return DateTime(dateOnly.year, dateOnly.month + 1, dateOnly.day);
      case RepeatFrequency.yearly:
        return DateTime(dateOnly.year + 1, dateOnly.month, dateOnly.day);
      case RepeatFrequency.none:
        return dateOnly;
    }
  }
}
