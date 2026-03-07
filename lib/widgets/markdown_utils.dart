import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class MarkdownUtils {
  MarkdownUtils._();

  static List<String> extractCheckboxTexts(String data) {
    final List<String> texts = [];
    final lines = data.split('\n');
    for (final line in lines) {
      final match = RegExp(r'^\s*[-*]\s+\[[ xX]\]\s+(.+)').firstMatch(line);
      if (match != null) {
        texts.add(match.group(1)!);
      }
    }
    return texts;
  }

  static Map<String, MarkdownElementBuilder> builders(BuildContext context) => {
        'highlight': HighlightBuilder(context),
      };

  static List<md.InlineSyntax> get inlineSyntaxes => [HighlightSyntax()];
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

class InteractiveCheckbox extends StatefulWidget {
  final Todo? todo;
  final bool initialValue;
  final String text;

  const InteractiveCheckbox({
    super.key,
    this.todo,
    required this.initialValue,
    required this.text,
  });

  @override
  State<InteractiveCheckbox> createState() => _InteractiveCheckboxState();
}

class _InteractiveCheckboxState extends State<InteractiveCheckbox> {
  late bool _val;

  @override
  void initState() {
    super.initState();
    _val = widget.initialValue;
  }

  @override
  void didUpdateWidget(InteractiveCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _val = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.todo == null) return;
        final newVal = !_val;
        setState(() => _val = newVal);
        context.read<TodoProvider>().toggleMarkdownCheckbox(widget.todo!, widget.text, newVal);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          _val ? Icons.check_box : Icons.check_box_outline_blank,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
