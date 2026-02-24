import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slate/constants/app_strings.dart';
import 'package:slate/models/todo.dart';

import '../providers/todo_provider.dart';
import 'todo_tile.dart';

class StatusSection extends StatefulWidget {
  final Status status;
  final List<Todo> todos;
  /// When true, show all tasks (no "show more" limit). Use when a single
  /// status filter is selected.
  final bool expandAll;

  const StatusSection({
    super.key,
    required this.status,
    required this.todos,
    this.expandAll = false,
  });

  @override
  State<StatusSection> createState() => _StatusSectionState();
}

class _StatusSectionState extends State<StatusSection> {
  static const int previewCount = 3;

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.todos.isEmpty) return const SizedBox.shrink();

    final useLimit = !widget.expandAll;
    final visibleTodos = useLimit && !expanded
        ? widget.todos.take(previewCount).toList()
        : widget.todos;
    final remaining = widget.todos.length - previewCount;
    final showMoreButton = useLimit && remaining > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusHeader(
          status: widget.status,
          count: widget.todos.length,
          visibleTodos: widget.todos,
        ),

        ...visibleTodos.map((t) => TodoTile(todo: t)),

        if (showMoreButton)
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => setState(() => expanded = !expanded),
            child: Text(
              expanded
                  ? SectionStrings.showLess
                  : SectionStrings.showMore(remaining),
            ),
          ),
      ],
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final Status status;
  final int count;
  final List<Todo>? visibleTodos;

  const _StatusHeader({
    required this.status,
    required this.count,
    this.visibleTodos,
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

              if (status == Status.completed && count > 0)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: TooltipStrings.clearVisible,
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
        title: const Text(DialogStrings.clearCompletedTitle),
        content: Text(
          DialogStrings.clearCompletedContent(todos.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(BtnStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTodos(todos);
              Navigator.pop(context);
            },
            child: const Text(BtnStrings.delete),
          ),
        ],
      ),
    );
  }
}

