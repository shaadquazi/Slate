import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:slate/l10n/generated/app_localizations.dart';
import '../models/todo.dart';
import 'markdown_utils.dart';

class MarkdownDescriptionField extends StatefulWidget {
  final TextEditingController controller;
  final bool startWithPreview;
  final Todo? todo;

  const MarkdownDescriptionField({
    super.key,
    required this.controller,
    this.startWithPreview = false,
    this.todo,
  });

  @override
  State<MarkdownDescriptionField> createState() => _MarkdownDescriptionFieldState();
}

class _MarkdownDescriptionFieldState extends State<MarkdownDescriptionField> {
  bool _isPreview = false;

  @override
  void initState() {
    super.initState();
    _isPreview = widget.startWithPreview && widget.controller.text.isNotEmpty;
  }

  void _insertMarkdown(String prefix, [String suffix = '']) {
    final selection = widget.controller.selection;
    final text = widget.controller.text;
    
    int start = selection.start;
    int end = selection.end;
    
    if (start < 0) start = text.length;
    if (end < 0) end = text.length;

    final selectedText = text.substring(start, end);
    final newText = text.replaceRange(start, end, '$prefix$selectedText$suffix');

    widget.controller.value = widget.controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + prefix.length + selectedText.length + suffix.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide >= 600;

    final dynamicMaxLines = isTablet ? 20 : 10;
    final dynamicMaxHeight = isTablet ? 480.0 : 240.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.editTodo.split(' ')[0]), icon: const Icon(Icons.edit, size: 16)),
                ButtonSegment(value: true, label: const Text('Preview'), icon: const Icon(Icons.remove_red_eye, size: 16)),
              ],
              selected: {_isPreview},
              onSelectionChanged: (val) => setState(() => _isPreview = val.first),
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
            if (!_isPreview)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ToolbarButton(icon: Icons.format_bold, onTap: () => _insertMarkdown('**', '**')),
                      _ToolbarButton(icon: Icons.format_italic, onTap: () => _insertMarkdown('_', '_')),
                      _ToolbarButton(icon: Icons.format_list_bulleted, onTap: () => _insertMarkdown('\n* ')),
                      _ToolbarButton(icon: Icons.check_box_outlined, onTap: () => _insertMarkdown('\n* [ ] ')),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isPreview
              ? ConstrainedBox(
                  key: const ValueKey('preview'),
                  constraints: BoxConstraints(
                    minHeight: 100,
                    maxHeight: dynamicMaxHeight,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: SingleChildScrollView(
                      child: _AddEditPreview(
                        data: widget.controller.text,
                        todo: widget.todo,
                      ),
                    ),
                  ),
                )
              : TextFormField(
                  key: const ValueKey('edit'),
                  controller: widget.controller,
                  maxLines: dynamicMaxLines,
                  minLines: 4,
                  autofocus: !widget.startWithPreview,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.addDescription,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
        ),
      ],
    );
  }
}

class _AddEditPreview extends StatelessWidget {
  final String data;
  final Todo? todo;

  const _AddEditPreview({required this.data, this.todo});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Text('*No description*', style: TextStyle(fontStyle: FontStyle.italic));

    final checkboxTexts = MarkdownUtils.extractCheckboxTexts(data);
    int checkboxIndex = 0;

    return MarkdownBody(
      data: data,
      selectable: true,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: MarkdownUtils.inlineSyntaxes,
      builders: MarkdownUtils.builders(context),
      checkboxBuilder: (bool? checked) {
        final index = checkboxIndex++;
        if (index >= checkboxTexts.length) return const Icon(Icons.check_box_outline_blank, size: 18);
        return InteractiveCheckbox(
          todo: todo,
          initialValue: checked ?? false,
          text: checkboxTexts[index],
        );
      },
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ToolbarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(),
    );
  }
}
