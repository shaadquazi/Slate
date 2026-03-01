import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slate/models/todo.dart';
import 'package:slate/l10n/generated/app_localizations.dart';

import '../providers/todo_provider.dart';

class HomeFilters extends StatelessWidget {
  const HomeFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _FilterDropdownButton<DateFilter>(
            label: l10n.due,
            options: TodoProvider.dateFilterOptions,
            optionLabel: (d) => d.label,
            selected: provider.dateFilters,
            isAllSelected: provider.dateFilters.isEmpty ||
                provider.dateFilters.length ==
                    TodoProvider.dateFilterOptions.length,
            onToggle: provider.toggleDateFilter,
            selectedFromProvider: (p) => p.dateFilters,
          ),
          _FilterDropdownButton<Status>(
            label: l10n.status,
            options: Status.values,
            optionLabel: (s) => s.label,
            selected: provider.statusFilters,
            isAllSelected: provider.statusFilters.isEmpty ||
                provider.statusFilters.length == Status.values.length,
            onToggle: provider.toggleStatusFilter,
            selectedFromProvider: (p) => p.statusFilters,
          ),
        ],
      ),
    );
  }
}

class _FilterDropdownButton<T> extends StatelessWidget {
  final String label;
  final List<T> options;
  final String Function(T) optionLabel;
  final Set<T> selected;
  final bool isAllSelected;
  final ValueChanged<T> onToggle;
  final Set<T> Function(TodoProvider) selectedFromProvider;

  const _FilterDropdownButton({
    required this.label,
    required this.options,
    required this.optionLabel,
    required this.selected,
    required this.isAllSelected,
    required this.onToggle,
    required this.selectedFromProvider,
  });

  String _summary(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isAllSelected) return l10n.all;
    final text = selected.map(optionLabel).join(', ');
    return text.length > 18 ? '${text.substring(0, 15)}...' : text;
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _showFilterSheet(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Text(
            _summary(context),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 20),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(sheetContext).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Consumer<TodoProvider>(
                builder: (_, provider, _) {
                  final currentSelected = selectedFromProvider(provider);
                  return Column(
                    children: [
                      for (final option in options)
                        CheckboxListTile(
                          value: currentSelected.contains(option),
                          title: Text(optionLabel(option)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (_) => onToggle(option),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
