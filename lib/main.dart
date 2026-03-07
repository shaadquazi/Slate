import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:slate/screens/error_app.dart';
import 'package:slate/theme/app_theme.dart';
import 'package:slate/utils/logger.dart';
import 'package:slate/l10n/generated/app_localizations.dart';

import 'models/todo.dart';
import 'providers/todo_provider.dart';
import 'repositories/todo_repository.dart';
import 'services/todo_service.dart';
import 'constants/app_constants.dart';
import 'screens/home_screen.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        logger.e('Flutter error: ${details.exception}', error: details.exception, stackTrace: details.stack);
      };

      try {
        await Hive.initFlutter();

        Hive.registerAdapter(TodoAdapter());
        Hive.registerAdapter(StatusAdapter());
        Hive.registerAdapter(RepeatFrequencyAdapter());

        final todoBox = await Hive.openBox<Todo>(AppConstants.todoBoxName);
        final settingsBox = await Hive.openBox(AppConstants.settingsBoxName);

        final repository = TodoRepository(todoBox, settingsBox);
        final service = TodoService(repository);

        runApp(
          MultiProvider(
            providers: [
              Provider.value(value: repository),
              Provider.value(value: service),
              ChangeNotifierProvider(
                create: (_) => TodoProvider(repository, service)..loadTodos(),
              ),
            ],
            child: const MyApp(),
          ),
        );
      } catch (e, stack) {
        logger.e('Startup error', error: e, stackTrace: stack);
        runApp(const ErrorApp());
      }
    },
    (error, stack) {
      logger.e('Unhandled error', error: error, stackTrace: stack);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      theme: primaryTheme,
      darkTheme: secondaryTheme,
      themeMode: provider.themeMode,
      locale: provider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      home: const HomeScreen(),
    );
  }
}
