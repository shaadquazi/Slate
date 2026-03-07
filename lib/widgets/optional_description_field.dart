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
      return SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: () => setState(() => _showField = true),
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.addDescription),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4, // Grow up to 40% of screen height
      ),
      child: TextFormField(
        controller: widget.controller,
        maxLines: null,
        minLines: 1,
        autofocus: true,
        keyboardType: TextInputType.multiline,
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
      ),
    );

  }
}

