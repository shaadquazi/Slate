import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../models/todo.dart';
import '../repositories/todo_repository.dart';
import '../services/todo_service.dart';

enum DateFilter { daily, weekly, monthly, yearly }

extension DateFilterX on DateFilter {
  String get label {
    switch (this) {
      case DateFilter.daily:
        return 'Today';
      case DateFilter.weekly:
        return 'This week';
      case DateFilter.monthly:
        return 'This month';
      case DateFilter.yearly:
        return 'This year';
    }
  }
}

class TodoProvider extends ChangeNotifier {
  final TodoRepository _repository;
  final TodoService _service;

  TodoProvider(this._repository, this._service);

  static const String statusFiltersKey = 'status_filters';
  static const String dateFiltersKey = 'date_filters';

  Set<Status> _statusFilters = {};
  Set<DateFilter> _dateFilters = {};

  Set<Status> get statusFilters => Set.from(_statusFilters);
  Set<DateFilter> get dateFilters => Set.from(_dateFilters);

  static const List<DateFilter> dateFilterOptions = DateFilter.values;

  List<Todo> _todos = [];

  void setStatusFilters(Set<Status> value) {
    _statusFilters = Set.from(value);
    _saveSettings();
    notifyListeners();
  }

  void setDateFilters(Set<DateFilter> value) {
    _dateFilters = Set.from(value);
    _saveSettings();
    notifyListeners();
  }

  void toggleStatusFilter(Status s) {
    if (_statusFilters.contains(s)) {
      _statusFilters = Set.from(_statusFilters)..remove(s);
    } else {
      _statusFilters = Set.from(_statusFilters)..add(s);
    }
    _saveSettings();
    notifyListeners();
  }

  void toggleDateFilter(DateFilter d) {
    if (_dateFilters.contains(d)) {
      _dateFilters = Set.from(_dateFilters)..remove(d);
    } else {
      _dateFilters = Set.from(_dateFilters)..add(d);
    }
    _saveSettings();
    notifyListeners();
  }

  List<Todo> get _filtered {
    return _service.getFilteredTodos(
      allTodos: _todos,
      statusFilters: _statusFilters,
      dateFilters: _dateFilters,
    );
  }

  List<Todo> _sort(List<Todo> list) {
    list.sort((a, b) {
      if (a.dueDate != null && b.dueDate != null) {
        final cmp = a.dueDate!.compareTo(b.dueDate!);
        if (cmp != 0) return cmp;
      } else if (a.dueDate != null && b.dueDate == null) {
        return -1;
      } else if (a.dueDate == null && b.dueDate != null) {
        return 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  List<Todo> get pendingTodos => _sort(_filtered.where((t) => t.status == Status.pending).toList());
  List<Todo> get currentTodos => _sort(_filtered.where((t) => t.status == Status.inProgress).toList());
  List<Todo> get completedTodos => _sort(_filtered.where((t) => t.status == Status.completed).toList());

  Future<void> loadTodos() async {
    _todos = _repository.getAllTodos();
    _loadSettings();
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    await _repository.saveTodo(todo);
    _todos.add(todo);
    notifyListeners();
  }

  Future<void> createAndAddTodo({
    required String title,
    required String description,
    required Status status,
    required RepeatFrequency repeat,
    DateTime? repeatEndDate,
    DateTime? dueDate,
    Uint8List? imageBytes,
  }) async {
    final todo = await _service.createTodo(
      title: title,
      description: description,
      status: status,
      repeat: repeat,
      repeatEndDate: repeatEndDate,
      dueDate: dueDate,
      imageBytes: imageBytes,
    );
    await addTodo(todo);
  }

  Future<void> deleteTodo(Todo todo) async {
    await _repository.deleteTodo(todo);
    _todos.remove(todo);
    notifyListeners();
  }

  Future<void> deleteTodos(List<Todo> todos) async {
    for (final t in todos) {
      await _repository.deleteTodo(t);
    }
    _todos.removeWhere((t) => todos.contains(t));
    notifyListeners();
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
    await _service.updateTodo(
      todo,
      title: title,
      description: description,
      status: status,
      repeat: repeat,
      repeatEndDate: repeatEndDate,
      dueDate: dueDate,
      imageBytes: imageBytes,
      clearDueDate: clearDueDate,
    );
    _todos = _repository.getAllTodos();
    notifyListeners();
  }

  Future<void> updateStatus(Todo todo, Status status) async {
    await updateTodo(todo, status: status);
  }

  void _saveSettings() {
    _repository.saveSettings(statusFiltersKey, _statusFilters.map((s) => s.index).toList());
    _repository.saveSettings(dateFiltersKey, _dateFilters.map((d) => d.index).toList());
  }

  void _loadSettings() {
    final statusIndices = _repository.getSetting(statusFiltersKey) as List?;
    if (statusIndices != null) {
      _statusFilters = statusIndices.map((i) => Status.values[i as int]).toSet();
    }
    final dateIndices = _repository.getSetting(dateFiltersKey) as List?;
    if (dateIndices != null) {
      _dateFilters = dateIndices.map((i) => DateFilter.values[i as int]).toSet();
    }
  }

  Future<void> clearCompleted() async {
    final completed = _todos.where((t) => t.status == Status.completed).toList();
    await deleteTodos(completed);
  }
}
