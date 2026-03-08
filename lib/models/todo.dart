import 'package:hive/hive.dart';
import 'dart:typed_data';
import '../l10n/generated/app_localizations.dart';

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
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case Status.pending:
        return l10n.pending;
      case Status.inProgress:
        return l10n.inProgress;
      case Status.completed:
        return l10n.completed;
    }
  }

  String labelWithOptionalCount(int count, AppLocalizations l10n) {
    final label = localizedLabel(l10n);
    return count > 3 ? '$label ($count)' : label;
  }

  Status? get next {
    switch (this) {
      case Status.pending:
        return Status.inProgress;
      case Status.inProgress:
        return Status.completed;
      case Status.completed:
        return null;
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

  @HiveField(12)
  bool isDeleted;

  @HiveField(13)
  DateTime? deletedAt;

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
    this.isDeleted = false,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'repeat': repeat.index,
      'repeatEndDate': repeatEndDate?.toIso8601String(),
      'completedOn': completedOn?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'imagePath': imagePath,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse int fields that might come as strings or invalid values
    int parseEnum(dynamic value, int length, int defaultValue) {
      if (value is int && value >= 0 && value < length) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null && parsed >= 0 && parsed < length) return parsed;
      }
      return defaultValue;
    }

    return Todo(
      id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      status: Status.values[parseEnum(json['status'], Status.values.length, 0)],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      repeat: RepeatFrequency.values[parseEnum(json['repeat'], RepeatFrequency.values.length, 0)],
      repeatEndDate: json['repeatEndDate'] != null ? DateTime.tryParse(json['repeatEndDate'].toString()) : null,
      completedOn: json['completedOn'] != null ? DateTime.tryParse(json['completedOn'].toString()) : null,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'].toString()) : null,
      imagePath: json['imagePath'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null ? DateTime.tryParse(json['deletedAt'].toString()) : null,
    );
  }
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
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case RepeatFrequency.none:
        return l10n.none;
      case RepeatFrequency.daily:
        return l10n.daily;
      case RepeatFrequency.weekly:
        return l10n.weekly;
      case RepeatFrequency.monthly:
        return l10n.monthly;
      case RepeatFrequency.yearly:
        return l10n.yearly;
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

enum DateFilter { daily, weekly, rollingWeek, monthly, yearly }

extension DateFilterX on DateFilter {
  String label(AppLocalizations l10n) {
    switch (this) {
      case DateFilter.daily:
        return l10n.today;
      case DateFilter.weekly:
        return l10n.thisWeek;
      case DateFilter.rollingWeek:
        return l10n.nextSevenDays;
      case DateFilter.monthly:
        return l10n.thisMonth;
      case DateFilter.yearly:
        return l10n.thisYear;
    }
  }
}
