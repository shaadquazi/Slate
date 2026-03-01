import 'dart:typed_data';
import '../models/todo.dart';
import '../repositories/todo_repository.dart';
import '../providers/todo_provider.dart';
import 'package:flutter/material.dart';

class TodoService {
  final TodoRepository _repository;

  TodoService(this._repository);

  List<Todo> getFilteredTodos({
    required List<Todo> allTodos,
    required Set<Status> statusFilters,
    required Set<DateFilter> dateFilters,
  }) {
    final statusFilterIsAll = statusFilters.isEmpty || statusFilters.length == Status.values.length;
    final dateFilterOptions = DateFilter.values;
    final dateFilterIsAll = dateFilters.isEmpty || dateFilters.length == dateFilterOptions.length;

    return allTodos.where((t) {
      final statusMatch = statusFilterIsAll || statusFilters.contains(t.status);
      final dateMatch = _matchesDateFilter(t, dateFilters, dateFilterIsAll);
      return statusMatch && dateMatch;
    }).toList();
  }

  bool _matchesDateFilter(Todo t, Set<DateFilter> dateFilters, bool isAll) {
    if (t.dueDate == null) return true;
    if (isAll) return true;

    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final due = DateUtils.dateOnly(t.dueDate!);

    for (final filter in dateFilters) {
      switch (filter) {
        case DateFilter.daily:
          if (DateUtils.isSameDay(due, today)) return true;
        case DateFilter.weekly:
          if (_isSameWeek(due, today)) return true;
        case DateFilter.monthly:
          if (due.year == today.year && due.month == today.month) return true;
        case DateFilter.yearly:
          if (due.year == today.year) return true;
      }
    }
    return false;
  }

  bool _isSameWeek(DateTime date, DateTime now) {
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    return !date.isBefore(firstDayOfWeek) && !date.isAfter(lastDayOfWeek);
  }

  Future<Todo> createTodo({
    required String title,
    required String description,
    required Status status,
    required RepeatFrequency repeat,
    DateTime? repeatEndDate,
    DateTime? dueDate,
    Uint8List? imageBytes,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    String? imagePath;
    Uint8List? savedBytes;

    if (imageBytes != null) {
      final result = await _repository.saveImage(imageBytes, id);
      if (result is String) {
        imagePath = result;
      } else if (result is Uint8List) {
        savedBytes = result;
      }
    }

    return Todo(
      id: id,
      title: title,
      description: description,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      repeat: repeat,
      repeatEndDate: repeatEndDate,
      dueDate: dueDate,
      imagePath: imagePath,
      imageBytes: savedBytes,
    );
  }

  Future<void> updateTodo(Todo todo, {
    String? title,
    String? description,
    Status? status,
    RepeatFrequency? repeat,
    DateTime? repeatEndDate,
    DateTime? dueDate,
    Uint8List? imageBytes,
    bool clearDueDate = false,
  }) async {
    if (title != null) todo.title = title;
    if (description != null) todo.description = description;
    if (repeat != null) todo.repeat = repeat;
    if (repeatEndDate != null) todo.repeatEndDate = repeatEndDate;
    if (clearDueDate) {
      todo.dueDate = null;
    } else if (dueDate != null) {
      todo.dueDate = dueDate;
    }

    if (imageBytes != null) {
      final result = await _repository.saveImage(imageBytes, todo.id);
      if (result is String) {
        todo.imagePath = result;
        todo.imageBytes = null;
      } else if (result is Uint8List) {
        todo.imageBytes = result;
        todo.imagePath = null;
      }
    }

    bool statusChanged = false;
    if (status != null && todo.status != status) {
      todo.status = status;
      statusChanged = true;
      if (status == Status.completed) {
        todo.completedOn = DateTime.now();
      }
    }

    todo.updatedAt = DateTime.now();
    await _repository.saveTodo(todo);

    if (statusChanged && todo.status == Status.completed && todo.repeat != RepeatFrequency.none) {
      await _handleRepetition(todo);
    }
  }

  Future<void> _handleRepetition(Todo old) async {
    final DateTime baseDate = old.dueDate ?? old.completedOn ?? old.createdAt;
    final DateTime nextDueDate = old.repeat.calculateNext(baseDate);

    if (old.repeatEndDate != null && nextDueDate.isAfter(old.repeatEndDate!)) {
      return;
    }

    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: old.title,
      description: old.description,
      status: Status.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      repeat: old.repeat,
      repeatEndDate: old.repeatEndDate,
      imagePath: old.imagePath,
      imageBytes: old.imageBytes,
      dueDate: nextDueDate,
    );

    await _repository.saveTodo(newTodo);
  }
}
