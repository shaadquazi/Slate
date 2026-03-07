import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slate/models/todo.dart';
import 'package:slate/l10n/generated/app_localizations.dart';

import '../providers/todo_provider.dart';
import 'todo_tile.dart';

class StatusSection extends StatefulWidget {
  final Status status;
  final List<Todo> todos;
  final bool expandAll;
  final VoidCallback? onNavigate;

  const StatusSection({
    super.key,
    required this.status,
    required this.todos,
    this.expandAll = false,
    this.onNavigate,
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

    final l10n = AppLocalizations.of(context)!;
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

        ...visibleTodos.map((t) => TodoTile(todo: t, onNavigate: widget.onNavigate)),

        if (showMoreButton)
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => setState(() => expanded = !expanded),
            child: Text(
              expanded
                  ? l10n.showLess
                  : l10n.showMore(remaining),
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
    final l10n = AppLocalizations.of(context)!;

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
                  status.labelWithOptionalCount(count, l10n),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (status == Status.completed && count > 0)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: l10n.clearVisible,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.clearCompletedTitle),
        content: Text(
          l10n.clearCompletedContent(todos.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTodos(todos);
              Navigator.pop(context);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
