import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slate/constants/app_strings.dart';
import 'package:slate/models/todo.dart';

import '../providers/todo_provider.dart';
import '../widgets/home_filters.dart';
import '../widgets/status_section.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.appName,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          const HomeFilters(),

          Expanded(
            child: Builder(
              builder: (_) {
                final pending = provider.pendingTodos;
                final current = provider.currentTodos;
                final completed = provider.completedTodos;

                if (pending.isEmpty && current.isEmpty && completed.isEmpty) {
                  return const Center(child: Text(MsgStrings.noTasks));
                }

                final singleStatusFilter = provider.statusFilters.length == 1;
                return ListView(
                  children: [
                    StatusSection(
                      status: Status.pending,
                      todos: pending,
                      expandAll: singleStatusFilter,
                    ),
                    StatusSection(
                      status: Status.inProgress,
                      todos: current,
                      expandAll: singleStatusFilter,
                    ),
                    StatusSection(
                      status: Status.completed,
                      todos: completed,
                      expandAll: singleStatusFilter,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
