import 'package:flutter/material.dart';

class OptionalDescriptionField extends StatefulWidget {
  final TextEditingController controller;

  const OptionalDescriptionField({super.key, required this.controller});

  @override
  State<OptionalDescriptionField> createState() =>
      _OptionalDescriptionFieldState();
}

class _OptionalDescriptionFieldState extends State<OptionalDescriptionField> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // left align everything
      children: [
        // "Add description" button
        if (!isExpanded)
          Align(
            alignment: Alignment.centerLeft, // ensures left alignment
            child: TextButton.icon(
              onPressed: () => setState(() => isExpanded = true),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                "Add description",
                style: TextStyle(fontSize: 16),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero, // remove default padding
                minimumSize: const Size(0, 0), // shrink button
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft, // make icon+text flush left
              ),
            ),
          ),
        // TextFormField when expanded
        if (isExpanded)
          TextFormField(
            controller: widget.controller,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 3,
            maxLines: null,
            expands: false,
            decoration: InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ), // consistent padding
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    isExpanded = false;
                    widget.controller.clear();
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}
