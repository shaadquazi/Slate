import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/todo.dart';
import '../repositories/todo_repository.dart';
import '../services/todo_service.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class TodoProvider extends ChangeNotifier {
  final TodoRepository _repository;
  final TodoService _service;

  TodoProvider(this._repository, this._service);

  Set<Status> _statusFilters = {};
  Set<DateFilter> _dateFilters = {};
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  String _appVersion = '';
  String _searchQuery = '';

  Set<Status> get statusFilters => Set.from(_statusFilters);
  Set<DateFilter> get dateFilters => Set.from(_dateFilters);
  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  String get appVersion => _appVersion;
  String get searchQuery => _searchQuery;

  bool get isFilterActive => _statusFilters.isNotEmpty || _dateFilters.isNotEmpty;

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

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearAllFilters() {
    _statusFilters = {};
    _dateFilters = {};
    _saveSettings();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _repository.saveSettings(AppConstants.themeModeKey, mode.index);
    notifyListeners();
  }

  void setLocale(Locale? locale) {
    _locale = locale;
    _repository.saveSettings(AppConstants.localeKey, locale?.languageCode);
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
      searchQuery: _searchQuery,
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
  List<Todo> get trashedTodos => _service.getTrashedTodos(_todos);

  Future<void> loadTodos() async {
    _todos = _repository.getAllTodos();
    _loadSettings();
    await _loadAppInfo();
    await _service.autoCleanupTrash(_todos);
    _todos = _repository.getAllTodos(); 
    notifyListeners();
  }

  Future<void> _loadAppInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appVersion = 'Version ${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      logger.e('Error loading app version', error: e);
    }
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

  Future<void> trashTodo(Todo todo) async {
    await _service.trashTodo(todo);
    notifyListeners();
  }

  Future<void> restoreTodo(Todo todo) async {
    await _service.restoreTodo(todo);
    notifyListeners();
  }

  Future<void> permanentDeleteTodo(Todo todo) async {
    await _service.permanentDeleteTodo(todo);
    _todos.remove(todo);
    notifyListeners();
  }

  Future<void> emptyTrash() async {
    await _service.emptyTrash(_todos);
    _todos.removeWhere((t) => t.isDeleted);
    notifyListeners();
  }

  Future<void> deleteTodo(Todo todo) async {
    await trashTodo(todo);
  }

  Future<void> deleteTodos(List<Todo> todos) async {
    for (final t in todos) {
      await trashTodo(t);
    }
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

  Future<void> toggleMarkdownCheckbox(Todo todo, String text, bool checked) async {
    if (text.trim().isEmpty) return;
    final lines = todo.description.split('\n');
    final escapedText = RegExp.escape(text.trim());
    
    final regex = RegExp(r'^\s*[-*]\s+\[[ xX]\]\s+' + escapedText + r'\s*$');

    for (int i = 0; i < lines.length; i++) {
      if (regex.hasMatch(lines[i])) {
        final replacement = checked ? 'x' : ' ';
        lines[i] = lines[i].replaceFirst(RegExp(r'\[[ xX]\]'), '[$replacement]');
        break;
      }
    }
    await updateTodo(todo, description: lines.join('\n'));
  }

  Future<void> updateStatus(Todo todo, Status status) async {
    await updateTodo(todo, status: status);
  }

  void _saveSettings() {
    _repository.saveSettings(AppConstants.statusFiltersKey, _statusFilters.map((s) => s.index).toList());
    _repository.saveSettings(AppConstants.dateFiltersKey, _dateFilters.map((d) => d.index).toList());
  }

  void _loadSettings() {
    try {
      final statusIndices = _repository.getSetting(AppConstants.statusFiltersKey);
      if (statusIndices is List) {
        _statusFilters = statusIndices
            .where((i) => i is int && i >= 0 && i < Status.values.length)
            .map((i) => Status.values[i as int])
            .toSet();
      }

      final dateIndices = _repository.getSetting(AppConstants.dateFiltersKey);
      if (dateIndices is List) {
        _dateFilters = dateIndices
            .where((i) => i is int && i >= 0 && i < DateFilter.values.length)
            .map((i) => DateFilter.values[i as int])
            .toSet();
      }

      final themeIndex = _repository.getSetting(AppConstants.themeModeKey);
      if (themeIndex is int && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
      }

      final langCode = _repository.getSetting(AppConstants.localeKey);
      if (langCode is String) {
        _locale = Locale(langCode);
      }
    } catch (e) {
      logger.e('Error loading settings', error: e);
      _statusFilters = {};
      _dateFilters = {};
      _themeMode = ThemeMode.system;
      _locale = null;
    }
  }

  Future<void> clearCompleted() async {
    final completed = _todos.where((t) => t.status == Status.completed).toList();
    await deleteTodos(completed);
  }

  Future<void> resetApp() async {
    for (final t in _todos) {
      if (!t.isDeleted) {
        await trashTodo(t);
      }
    }
    notifyListeners();
  }

  Future<void> exportData() async {
    await _repository.exportData();
  }

  Future<int> importData(String jsonString) async {
    final count = await _repository.importData(jsonString);
    _todos = _repository.getAllTodos();
    notifyListeners();
    return count;
  }
}
