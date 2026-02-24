import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:slate/constants/app_strings.dart';
import 'package:slate/screens/error_app.dart';
import 'dart:async';

import 'models/todo.dart';
import 'providers/todo_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter error: ${details.exception}');
  };

  runZonedGuarded(
    () async {
      try {
        await Hive.initFlutter();

        Hive.registerAdapter(TodoAdapter());
        Hive.registerAdapter(StatusAdapter());
        Hive.registerAdapter(RepeatFrequencyAdapter());

        await Hive.openBox<Todo>('todos');

        runApp(const MyApp());
      } catch (e) {
        runApp(const ErrorApp());
      }
    },
    (error, stack) {
      debugPrint(error.toString());
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoProvider()..loadTodos(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          fontFamily: 'AppFont',

          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: Brightness.dark,
          ),

          scaffoldBackgroundColor: const Color(0xFF121212),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
