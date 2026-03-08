import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:slate/models/todo.dart';
import 'package:slate/l10n/generated/app_localizations.dart';
import 'package:slate/screens/trash_bin_screen.dart';

import '../providers/todo_provider.dart';
import '../widgets/status_section.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _clearSearch() {
    if (_isSearching) {
      setState(() {
        _isSearching = false;
        _searchCtrl.clear();
      });
      context.read<TodoProvider>().setSearchQuery('');
    }
  }

  void _showSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<TodoProvider>();
    final rootContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.settings,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(l10n.theme),
                trailing: DropdownButton<ThemeMode>(
                  value: provider.themeMode,
                  underline: const SizedBox(),
                  onChanged: (mode) {
                    if (mode != null) {
                      provider.setThemeMode(mode);
                      Navigator.pop(sheetContext);
                    }
                  },
                  items: [
                    DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.system)),
                    DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.light)),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.dark)),
                  ],
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.personalization,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.language),
                trailing: DropdownButton<String?>(
                  value: provider.locale?.languageCode,
                  underline: const SizedBox(),
                  onChanged: (code) {
                    provider.setLocale(code == null ? null : Locale(code));
                    Navigator.pop(sheetContext);
                  },
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.system)),
                    DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                    DropdownMenuItem(value: 'es', child: Text(l10n.spanish)),
                  ],
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.dataManagement,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: Text(l10n.exportData),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    await provider.exportData();
                  } catch (e) {
                    if (rootContext.mounted) {
                      ScaffoldMessenger.of(rootContext).showSnackBar(
                        SnackBar(content: Text('Export failed: $e')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.unarchive_outlined),
                title: Text(l10n.importData),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await Future.delayed(const Duration(milliseconds: 150));
                  if (rootContext.mounted) {
                    _handleImport(rootContext, provider);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.trashBin),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _clearSearch();
                  Navigator.push(
                    rootContext,
                    MaterialPageRoute(builder: (_) => const TrashBinScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
                title: Text(l10n.resetApp, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmReset(rootContext, provider);
                },
              ),
              const SizedBox(height: 24),
              Text(
                provider.appVersion,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _handleImport(BuildContext context, TodoProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null) return;

      String jsonString;
      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        if (bytes == null) throw 'No data received';
        jsonString = utf8.decode(bytes);
      } else {
        final path = result.files.single.path;
        final bytes = result.files.single.bytes;
        if (path != null) {
          final file = File(path);
          jsonString = await file.readAsString();
        } else if (bytes != null) {
          jsonString = utf8.decode(bytes);
        } else {
          throw 'Could not read file';
        }
      }

      if (jsonString.isEmpty) throw 'Selected file is empty';

      if (context.mounted) {
        _confirmImport(context, provider, jsonString);
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l10n.invalidFile),
            content: Text(e.toString()),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          ),
        );
      }
    }
  }

  void _confirmImport(BuildContext context, TodoProvider provider, String jsonString) {
    final l10n = AppLocalizations.of(context)!;
    int count = 0;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        count = decoded.length;
      } else if (decoded is Map && decoded.containsKey('todos')) {
        count = (decoded['todos'] as List).length;
      } else if (decoded is Map) {
        count = 1;
      }
    } catch (_) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.importConfirmTitle),
        content: Text(l10n.importConfirmContent(count)), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );
              }

              try {
                final importedCount = await provider.importData(jsonString);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${l10n.importSuccess} ($importedCount)')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l10n.invalidFile),
                      content: Text(e.toString()),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                    ),
                  );
                }
              }
            },
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Consumer<TodoProvider>(
        builder: (context, provider, _) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(l10n.filters, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.help_outline, 
                        size: 16, 
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
                      ),
                      onPressed: () => _showFilterHelp(context),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Spacer(),
                    if (provider.isFilterActive)
                      TextButton(
                        onPressed: provider.clearAllFilters,
                        child: Text(l10n.clearFilters),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l10n.due, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: DateFilter.values.map((d) => FilterChip(
                    label: Text(d.label(l10n)),
                    selected: provider.dateFilters.contains(d),
                    onSelected: (_) => provider.toggleDateFilter(d),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                Text(l10n.status, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: Status.values.map((s) => FilterChip(
                    label: Text(s.localizedLabel(l10n)),
                    selected: provider.statusFilters.contains(s),
                    onSelected: (_) => provider.toggleStatusFilter(s),
                  )).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterHelp(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.filterHelp),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HelpRow(label: l10n.today, help: l10n.filterHelpToday),
            _HelpRow(label: l10n.thisWeek, help: l10n.filterHelpThisWeek),
            _HelpRow(label: l10n.nextSevenDays, help: l10n.filterHelpIn7Days),
            _HelpRow(label: l10n.thisMonth, help: l10n.filterHelpThisMonth),
            _HelpRow(label: l10n.thisYear, help: l10n.filterHelpThisYear),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, TodoProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetAppConfirmTitle),
        content: Text(l10n.resetAppConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.resetApp();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.search,
                  border: InputBorder.none,
                ),
                onChanged: (v) => provider.setSearchQuery(v),
              )
            : Text(
                l10n.appName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              if (_isSearching) {
                _clearSearch();
              } else {
                setState(() => _isSearching = true);
              }
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterSheet(context),
              ),
              if (provider.isFilterActive)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _clearSearch();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (_) {
                final pending = provider.pendingTodos;
                final current = provider.currentTodos;
                final completed = provider.completedTodos;

                if (pending.isEmpty && current.isEmpty && completed.isEmpty) {
                  return Center(
                    child: Text(
                      provider.searchQuery.isEmpty ? l10n.noTasks : l10n.noResults,
                    ),
                  );
                }

                final singleStatusFilter = provider.statusFilters.length == 1;
                return ListView(
                  children: [
                    StatusSection(
                      status: Status.pending,
                      todos: pending,
                      expandAll: singleStatusFilter,
                      onNavigate: _clearSearch,
                    ),
                    StatusSection(
                      status: Status.inProgress,
                      todos: current,
                      expandAll: singleStatusFilter,
                      onNavigate: _clearSearch,
                    ),
                    StatusSection(
                      status: Status.completed,
                      todos: completed,
                      expandAll: singleStatusFilter,
                      onNavigate: _clearSearch,
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

class _HelpRow extends StatelessWidget {
  final String label;
  final String help;
  const _HelpRow({required this.label, required this.help});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text(help, style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 13))),
        ],
      ),
    );
  }
}
