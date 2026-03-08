import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slate/l10n/generated/app_localizations.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class TrashBinScreen extends StatelessWidget {
  const TrashBinScreen({super.key});

  static final _dateFormat = DateFormat.MMMd().add_jm();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final trashed = provider.trashedTodos;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trashBin),
        actions: [
          if (trashed.isNotEmpty)
            TextButton(
              onPressed: () => _confirmEmptyTrash(context, provider),
              child: Text(
                l10n.emptyTrash,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      body: trashed.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.trashEmpty,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: trashed.length,
              itemBuilder: (context, index) {
                final todo = trashed[index];
                return _TrashedTodoTile(todo: todo);
              },
            ),
    );
  }

  void _confirmEmptyTrash(BuildContext context, TodoProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.emptyTrashConfirmTitle),
        content: Text(l10n.emptyTrashConfirmContent),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.emptyTrash();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }
}

class _TrashedTodoTile extends StatelessWidget {
  final Todo todo;

  const _TrashedTodoTile({required this.todo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<TodoProvider>();

    return Dismissible(
      key: ValueKey('trash_${todo.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await _confirmPermanentDelete(context);
      },
      onDismissed: (_) {
        provider.permanentDeleteTodo(todo);
      },
      child: Opacity(
        opacity: 0.6,
        child: ListTile(
          title: Text(
            todo.title,
            style: const TextStyle(decoration: TextDecoration.lineThrough),
          ),
          subtitle: todo.deletedAt != null
              ? Text('${l10n.deletedAtPrefix} ${TrashBinScreen._dateFormat.format(todo.deletedAt!)}')
              : null,
          onTap: () => _confirmRestore(context, provider, todo),
        ),
      ),
    );
  }

  Future<bool?> _confirmPermanentDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permanentDelete),
        content: Text(l10n.resetAppConfirmContent), // Reuse generic delete warning
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _confirmRestore(BuildContext context, TodoProvider provider, Todo todo) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreTaskTitle),
        content: Text(l10n.restoreTaskContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.restoreTodo(todo);
              Navigator.pop(context);
            },
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
  }
}
