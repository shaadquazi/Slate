import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:typed_data';
import '../models/todo.dart';

class TodoProvider extends ChangeNotifier {
  late Box<Todo> _box;
  Status? _statusFilter;
  RepeatFrequency? _repeatFilter;

  Status? get statusFilter => _statusFilter;
  RepeatFrequency? get repeatFilter => _repeatFilter;

  List<Todo> _todos = [];

  void setStatusFilter(Status? s) {
    _statusFilter = s;
    notifyListeners();
  }

  void setRepeatFilter(RepeatFrequency? r) {
    _repeatFilter = r;
    notifyListeners();
  }

  List<Todo> get _baseFiltered {
    return _todos.where((t) {
      final statusMatch = _statusFilter == null || t.status == _statusFilter;

      final repeatMatch = _repeatFilter == null || t.repeat == _repeatFilter;

      return statusMatch && repeatMatch;
    }).toList();
  }

  List<Todo> _sort(List<Todo> list) {
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  List<Todo> get pendingTodos =>
      _sort(_baseFiltered.where((t) => t.status == Status.pending).toList());

  List<Todo> get currentTodos =>
      _sort(_baseFiltered.where((t) => t.status == Status.inProgress).toList());

  List<Todo> get completedTodos =>
      _sort(_baseFiltered.where((t) => t.status == Status.completed).toList());

  void loadTodos() {
    _box = Hive.box<Todo>('todos');
    _todos = _box.values.toList();
    notifyListeners();
  }

  void addTodo(Todo todo) {
    _box.put(todo.id, todo);
    _todos.add(todo);
    notifyListeners();
  }

  void deleteTodo(Todo todo) {
    todo.delete();
    _todos.remove(todo);
    notifyListeners();
  }

  void deleteTodos(List<Todo> todos) {
    for (final t in todos) {
      t.delete(); // Hive delete (or your storage delete)
    }

    _todos.removeWhere((t) => todos.contains(t));

    notifyListeners();
  }

  void updateTodo({
    required Todo todo,
    String? title,
    String? description,
    Status? status,
    RepeatFrequency? repeat,
    DateTime? repeatEndDate,
    Uint8List? imageBytes,
  }) {
    bool statusChanged = false;

    if (title != null) todo.title = title;
    if (description != null) todo.description = description;
    if (imageBytes != null) todo.imageBytes = imageBytes;

    if (status != null && todo.status != status) {
      todo.status = status;
      statusChanged = true;
    }

    if (repeat != null) todo.repeat = repeat;
    if (repeatEndDate != null) todo.repeatEndDate = repeatEndDate;

    todo.updatedAt = DateTime.now();

    if (statusChanged && todo.status == Status.completed) {
      todo.completedOn = DateTime.now();
    }

    todo.save();

    // Create next repeated task if completed
    if (statusChanged &&
        todo.status == Status.completed &&
        todo.repeat != RepeatFrequency.none) {
      _createNextRepeat(todo);
    }

    notifyListeners();
  }

  void updateStatus(Todo todo, Status status) {
    updateTodo(todo: todo, status: status);
  }

  void _createNextRepeat(Todo old) {
    DateTime nextDate = old.createdAt;

    switch (old.repeat) {
      case RepeatFrequency.daily:
        nextDate = nextDate.add(const Duration(days: 1));
        break;
      case RepeatFrequency.weekly:
        nextDate = nextDate.add(const Duration(days: 7));
        break;
      case RepeatFrequency.monthly:
        nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
        break;
      case RepeatFrequency.yearly:
        nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
        break;
      case RepeatFrequency.none:
        return; // no repeat
    }

    // Stop if next date is after repeatEndDate
    if (old.repeatEndDate != null && nextDate.isAfter(old.repeatEndDate!)) {
      return;
    }

    // Create a NEW Todo object (safe for Hive)
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: old.title,
      description: old.description,
      status: Status.pending,
      createdAt: nextDate,
      updatedAt: nextDate,
      repeat: old.repeat,
      repeatEndDate: old.repeatEndDate,
      imageBytes: old.imageBytes,
    );

    final box = Hive.box<Todo>('todos');
    box.add(newTodo);

    // Add to provider list so UI updates
    _todos.add(newTodo);

    notifyListeners();
  }

  void clearCompleted() {
    final completed = _todos
        .where((t) => t.status == Status.completed)
        .toList();

    for (final t in completed) {
      t.delete(); // Hive delete
    }

    _todos.removeWhere((t) => t.status == Status.completed);

    notifyListeners();
  }
}
