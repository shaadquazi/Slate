import 'dart:typed_data';
import '../models/todo.dart';
import '../repositories/todo_repository.dart';
import 'package:flutter/material.dart';

class TodoService {
  final TodoRepository _repository;

  TodoService(this._repository);

  List<Todo> getFilteredTodos({
    required List<Todo> allTodos,
    required Set<Status> statusFilters,
    required Set<DateFilter> dateFilters,
    String searchQuery = '',
  }) {
    final statusFilterIsAll = statusFilters.isEmpty || statusFilters.length == Status.values.length;
    final dateFilterOptions = DateFilter.values;
    final dateFilterIsAll = dateFilters.isEmpty || dateFilters.length == dateFilterOptions.length;

    final query = searchQuery.trim().toLowerCase();

    return allTodos.where((t) {
      if (t.isDeleted) return false;
      final statusMatch = statusFilterIsAll || statusFilters.contains(t.status);
      final dateMatch = _matchesDateFilter(t, dateFilters, dateFilterIsAll);
      
      bool searchMatch = true;
      if (query.isNotEmpty) {
        searchMatch = t.title.toLowerCase().contains(query) || 
                      t.description.toLowerCase().contains(query);
      }

      return statusMatch && dateMatch && searchMatch;
    }).toList();
  }

  List<Todo> getTrashedTodos(List<Todo> allTodos) {
    return allTodos
        .where((t) => t.isDeleted)
        .toList()
      ..sort((a, b) => (b.deletedAt ?? DateTime.now()).compareTo(a.deletedAt ?? DateTime.now()));
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
          if (!due.isAfter(today)) return true;
        case DateFilter.weekly:
          final lastDayOfWeek = today.add(Duration(days: 7 - today.weekday));
          if (!due.isAfter(lastDayOfWeek)) return true;
        case DateFilter.monthly:
          final lastDayOfMonth = DateTime(today.year, today.month + 1, 0);
          if (!due.isAfter(lastDayOfMonth)) return true;
        case DateFilter.yearly:
          final lastDayOfYear = DateTime(today.year, 12, 31);
          if (!due.isAfter(lastDayOfYear)) return true;
      }
    }
    return false;
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

  Future<void> trashTodo(Todo todo) async {
    todo.isDeleted = true;
    todo.deletedAt = DateTime.now();
    await _repository.saveTodo(todo);
  }

  Future<void> restoreTodo(Todo todo) async {
    todo.isDeleted = false;
    todo.deletedAt = null;
    await _repository.saveTodo(todo);
  }

  Future<void> permanentDeleteTodo(Todo todo) async {
    await _repository.deleteTodo(todo);
  }

  Future<void> emptyTrash(List<Todo> allTodos) async {
    final trashed = allTodos.where((t) => t.isDeleted).toList();
    for (final t in trashed) {
      await _repository.deleteTodo(t);
    }
  }

  Future<void> autoCleanupTrash(List<Todo> allTodos) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final toCleanup = allTodos.where((t) {
      return t.isDeleted && t.deletedAt != null && t.deletedAt!.isBefore(thirtyDaysAgo);
    }).toList();

    for (final t in toCleanup) {
      await _repository.deleteTodo(t);
    }
  }
}
