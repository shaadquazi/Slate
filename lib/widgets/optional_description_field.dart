import 'package:flutter/material.dart';
import 'package:slate/l10n/generated/app_localizations.dart';

class OptionalDescriptionField extends StatefulWidget {
  final TextEditingController controller;

  const OptionalDescriptionField({
    super.key,
    required this.controller,
  });

  @override
  State<OptionalDescriptionField> createState() =>
      _OptionalDescriptionFieldState();
}

class _OptionalDescriptionFieldState extends State<OptionalDescriptionField> {
  bool _showField = false;

  @override
  void initState() {
    super.initState();
    _showField = widget.controller.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_showField) {
      return OutlinedButton.icon(
        onPressed: () => setState(() => _showField = true),
        icon: const Icon(Icons.add, size: 18),
        label: Text(l10n.addDescription),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    return TextFormField(
      controller: widget.controller,
      maxLines: 3,
      minLines: 1,
      decoration: InputDecoration(
        labelText: l10n.description,
        hintText: l10n.addDescription,
        alignLabelWithHint: true,
        suffixIcon: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () {
            widget.controller.clear();
            setState(() => _showField = false);
          },
        ),
      ),
    );
  }
}
