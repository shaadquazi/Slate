import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:slate/l10n/generated/app_localizations.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../screens/add_edit_screen.dart';
import 'markdown_utils.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onNavigate;

  const TodoTile({super.key, required this.todo, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.horizontal,
      background: Builder(
        builder: (_) {
          IconData icon;

          switch (todo.status) {
            case Status.pending:
              icon = Icons.play_arrow;
              break;
            case Status.inProgress:
              icon = Icons.check;
              break;
            case Status.completed:
              icon = Icons.lock;
              break;
          }

          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.green,
            child: Icon(icon, color: Colors.white),
          );
        },
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        final provider = context.read<TodoProvider>();

        if (direction == DismissDirection.startToEnd) {
          final next = todo.status.next;

          if (next != null) {
            provider.updateStatus(todo, next);
          }

          return false;
        }

        if (direction == DismissDirection.endToStart) {
          return true;
        }

        return false;
      },
      onDismissed: (_) {
        context.read<TodoProvider>().deleteTodo(todo);
      },
      child: _TodoContent(todo: todo, onNavigate: onNavigate),
    );
  }
}

class _TodoContent extends StatefulWidget {
  final Todo todo;
  final VoidCallback? onNavigate;

  const _TodoContent({required this.todo, this.onNavigate});

  @override
  State<_TodoContent> createState() => _TodoContentState();
}

class _TodoContentState extends State<_TodoContent> {
  bool _isManuallyExpanded = false;
  static final _dateFormat = DateFormat.MMMd();

  Widget _highlightText(String text, String query, TextStyle style) {
    if (query.isEmpty) return Text(text, style: style);

    final parts = text.split(RegExp(query, caseSensitive: false));

    if (parts.length == 1) return Text(text, style: style);

    final List<TextSpan> spans = [];
    int start = 0;

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i], style: style));
        start += parts[i].length;
      }
      if (i < parts.length - 1) {
        final actualMatch = text.substring(start, start + query.length);
        spans.add(TextSpan(
          text: actualMatch,
          style: style.copyWith(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
            backgroundColor: Colors.amber.withValues(alpha: 0.4),
          ),
        ));
        start += query.length;
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  String _injectHighlightTags(String text, String query) {
    if (query.isEmpty) return text;
    return text.replaceAllMapped(RegExp(RegExp.escape(query), caseSensitive: false), (match) {
      return '==${match.group(0)}==';
    });
  }

  Widget? _buildTrailingDate(BuildContext context) {
    final todo = widget.todo;
    final DateTime? date;
    
    if (todo.status == Status.completed && todo.completedOn != null) {
      date = todo.completedOn;
    } else if ((todo.status == Status.pending || todo.status == Status.inProgress) && todo.dueDate != null) {
      date = todo.dueDate;
    } else {
      return null;
    }

    if (date == null) return null;

    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final comparisonDate = DateUtils.dateOnly(date);
    
    Color textColor = Theme.of(context).colorScheme.onSurface;
    FontWeight fontWeight = FontWeight.normal;

    if (todo.status != Status.completed && !comparisonDate.isAfter(today)) {
      fontWeight = FontWeight.bold;
      if (comparisonDate.isBefore(today)) {
        textColor = Theme.of(context).colorScheme.error;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        _dateFormat.format(date),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: fontWeight,
              fontSize: 12,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<TodoProvider>();
    final query = provider.searchQuery;
    
    final desc = widget.todo.description;
    final title = widget.todo.title;
    final hasDescription = desc.trim().isNotEmpty;
    final trailing = _buildTrailingDate(context);

    bool autoExpand = false;
    if (query.isNotEmpty) {
      final inTitle = title.toLowerCase().contains(query.toLowerCase());
      final inDesc = desc.toLowerCase().contains(query.toLowerCase());
      if (inDesc && !inTitle) {
        autoExpand = true;
      }
    }

    final isExpanded = _isManuallyExpanded || autoExpand;

    final isOverdue = widget.todo.dueDate != null && 
                      widget.todo.status != Status.completed &&
                      DateUtils.dateOnly(widget.todo.dueDate!).isBefore(DateUtils.dateOnly(DateTime.now()));

    final titleStyle = TextStyle(
      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
      color: isOverdue ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface,
    );

    const int descriptionThreshold = 100;
    final isLongDescription = desc.length > descriptionThreshold || desc.contains('\n');

    Widget buildMarkdown(bool expanded) {
      String data = expanded || !isLongDescription 
          ? desc 
          : '${desc.substring(0, math.min(desc.length, descriptionThreshold))}...';
      final checkboxTexts = MarkdownUtils.extractCheckboxTexts(data);
      int checkboxIndex = 0;

      if (query.isNotEmpty) {
        data = _injectHighlightTags(data, query);
      }

      final markdownWidget = MarkdownBody(
        data: data,
        selectable: false,
        extensionSet: md.ExtensionSet.gitHubFlavored,
        inlineSyntaxes: MarkdownUtils.inlineSyntaxes,
        builders: MarkdownUtils.builders(context),
        checkboxBuilder: (bool? checked) {
          final index = checkboxIndex++;
          if (index >= checkboxTexts.length) return const SizedBox.shrink();
          return InteractiveCheckbox(
            todo: widget.todo,
            initialValue: checked ?? false,
            text: checkboxTexts[index],
          );
        },
        styleSheet: MarkdownStyleSheet(
          p: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12,
              ),
        ),
      );

      if (!isLongDescription) return markdownWidget;

      if (expanded) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            markdownWidget,
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => setState(() => _isManuallyExpanded = false),
                child: Text(
                  l10n.less,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        final plainText = desc.replaceAll(RegExp(r'[*_#`\[\]]'), '').replaceAll('\n', ' ').trim();
        return Row(
          children: [
            Expanded(
              child: _highlightText(
                plainText, 
                query, 
                Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _isManuallyExpanded = true),
              child: Text(
                l10n.more,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      }
    }

    return ListTile(
      title: _highlightText(title, query, titleStyle),
      trailing: trailing,
      subtitle: hasDescription
          ? Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: buildMarkdown(isExpanded),
            )
          : null,
      onTap: () {
        widget.onNavigate?.call();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddEditScreen(todo: widget.todo)),
        );
      },
    );
  }
}

class HighlightSyntax extends md.InlineSyntax {
  HighlightSyntax() : super(r'==(.+?)==');

  @override
  bool onMatch(md.InlineParser parser, dynamic match) {
    parser.addNode(md.Element.text('highlight', match[1].toString()));
    return true;
  }
}


class HighlightBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  HighlightBuilder(this.context);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        element.textContent,
        style: preferredStyle?.copyWith(
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
