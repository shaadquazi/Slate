import 'package:flutter/material.dart';
import 'package:slate/constants/app_strings.dart';

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(ErrorStrings.genericStartup),
        ),
      ),
    );
  }
}
