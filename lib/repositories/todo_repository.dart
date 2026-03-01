import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/todo.dart';
import '../utils/logger.dart';

class TodoRepository {
  late Box<Todo> _box;
  late Box _settingsBox;

  static const String todoBoxName = 'todos';
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    _box = Hive.box<Todo>(todoBoxName);
    _settingsBox = Hive.box(settingsBoxName);
    logger.i('TodoRepository initialized');
  }

  List<Todo> getAllTodos() {
    return _box.values.toList();
  }

  Future<void> saveTodo(Todo todo) async {
    await _box.put(todo.id, todo);
  }

  Future<void> deleteTodo(Todo todo) async {
    if (todo.imagePath != null) {
      await _deleteImage(todo.imagePath!);
    }
    await todo.delete();
  }

  Future<dynamic> saveImage(Uint8List bytes, String id) async {
    if (kIsWeb) {
      return bytes;
    }
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDir.path, 'task_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(p.join(imagesDir.path, fileName));
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      logger.e('Error saving image: $e');
      return null;
    }
  }

  Future<void> _deleteImage(String path) async {
    if (kIsWeb) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      logger.e('Error deleting image: $e');
    }
  }

  // Settings
  Future<void> saveSettings(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  dynamic getSetting(String key) {
    return _settingsBox.get(key);
  }
}
