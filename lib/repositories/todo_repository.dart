import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../utils/logger.dart';
import '../utils/file_saver.dart';

class TodoRepository {
  final Box<Todo> _box;
  final Box _settingsBox;

  TodoRepository(this._box, this._settingsBox);

  List<Todo> getAllTodos() {
    return _box.values.toList();
  }

  Future<void> saveTodo(Todo todo) async {
    await _box.put(todo.id, todo);
  }

  Future<void> deleteTodo(Todo todo) async {
    if (todo.imagePath != null) {
      await deleteImage(todo.imagePath!);
    }
    await _box.delete(todo.id);
  }

  Future<dynamic> saveImage(Uint8List bytes, String fileName) async {
    if (kIsWeb) return bytes;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = p.join(directory.path, 'todo_images');
      await Directory(path).create(recursive: true);
      
      final filePath = p.join(path, '$fileName.jpg');
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      logger.e('Error saving image', error: e);
      return null;
    }
  }

  Future<void> deleteImage(String path) async {
    if (kIsWeb) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      logger.e('Error deleting image', error: e);
    }
  }

  Future<void> saveSettings(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  dynamic getSetting(String key) {
    return _settingsBox.get(key);
  }

  Future<void> clearAllData() async {
    await _box.clear();
    await _settingsBox.clear();
  }

  Future<void> exportData() async {
    try {
      final todos = getAllTodos();
      final jsonData = todos.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(jsonData);

      final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
      final fileName = 'Slate_$dateStr.json';

      if (kIsWeb) {
        await saveFileImplementation(fileName, jsonString);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = p.join(directory.path, fileName);
        final file = File(filePath);
        await file.writeAsString(jsonString);

        await Share.shareXFiles([XFile(filePath, name: fileName)], subject: 'Slate Backup');
      }
    } catch (e) {
      logger.e('Export failed', error: e);
      rethrow;
    }
  }

  Future<int> importData(String jsonString) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      
      List<dynamic> list;
      if (decoded is Map && decoded.containsKey('todos')) {
        list = decoded['todos'] as List<dynamic>;
      } else if (decoded is List) {
        list = decoded;
      } else {
        throw 'Invalid JSON structure: Expected List or Map with "todos" key';
      }

      int importedCount = 0;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            final todo = Todo.fromJson(item);
            await saveTodo(todo);
            importedCount++;
          } catch (itemError) {
            logger.w('Skipping invalid todo item: $itemError');
          }
        }
      }
      return importedCount;
    } catch (e) {
      logger.e('Import failed', error: e);
      rethrow;
    }
  }
}
