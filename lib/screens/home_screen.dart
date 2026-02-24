import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slate/constants/app_strings.dart';
import 'package:slate/models/todo.dart';

import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';
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
          _buildFilters(context),

          Expanded(
            child: Builder(
              builder: (_) {
                final pending = provider.pendingTodos;
                final current = provider.currentTodos;
                final completed = provider.completedTodos;

                if (pending.isEmpty && current.isEmpty && completed.isEmpty) {
                  return const Center(child: Text('No tasks'));
                }

                return ListView(
                  children: [
                    _StatusSection(status: Status.pending, todos: pending),
                    _StatusSection(status: Status.inProgress, todos: current),
                    _StatusSection(status: Status.completed, todos: completed),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final provider = context.watch<TodoProvider>();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: DropdownMenu<RepeatFrequency?>(
              initialSelection: provider.repeatFilter,
              label: const Text('Duration'),
              onSelected: provider.setRepeatFilter,
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'All'),
                ...RepeatFrequency.values
                    .where((r) => r != RepeatFrequency.none)
                    .map((r) => DropdownMenuEntry(value: r, label: r.label)),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: DropdownMenu<Status?>(
              initialSelection: provider.statusFilter,
              label: const Text('Status'),
              onSelected: provider.setStatusFilter,
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'All'),
                ...Status.values.map(
                  (s) => DropdownMenuEntry(value: s, label: s.label),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final Status status;
  final int count;
  final List<Todo>? visibleTodos; // 👈 new

  const _StatusHeader({
    required this.status,
    required this.count,
    this.visibleTodos,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TodoProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  status.labelWithOptionalCount(count),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              /// ✅ only for completed + visible items exist
              if (status == Status.completed && count > 0)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'Clear visible',
                  onPressed: () =>
                      _confirmClear(context, provider, visibleTodos ?? []),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmClear(
    BuildContext context,
    TodoProvider provider,
    List<Todo> todos,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear completed tasks?'),
        content: Text('Delete ${todos.length} visible tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTodos(todos); // 👈 filtered delete
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatusSection extends StatefulWidget {
  final Status status;
  final List<Todo> todos;

  const _StatusSection({required this.status, required this.todos});

  @override
  State<_StatusSection> createState() => _StatusSectionState();
}

class _StatusSectionState extends State<_StatusSection> {
  static const int previewCount = 3;

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.todos.isEmpty) return const SizedBox.shrink();

    final visibleTodos = expanded
        ? widget.todos
        : widget.todos.take(previewCount).toList();

    final remaining = widget.todos.length - previewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusHeader(
          status: widget.status,
          count: widget.todos.length,
          visibleTodos: widget.todos,
        ),

        ...visibleTodos.map((t) => TodoTile(todo: t)),

        if (remaining > 0)
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => setState(() => expanded = !expanded),
            child: Text(expanded ? 'Show less' : 'Show $remaining more'),
          ),
      ],
    );
  }
}
