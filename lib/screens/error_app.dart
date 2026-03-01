import 'package:flutter/material.dart';
import 'package:slate/l10n/generated/app_localizations.dart';

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context)?.genericStartup ?? 'Error'),
        ),
      ),
    );
  }
}
