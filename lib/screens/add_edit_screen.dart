import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:slate/screens/editable_image_field.dart';
import 'package:slate/widgets/image_picker_field.dart';
import 'package:slate/l10n/generated/app_localizations.dart';

import 'package:slate/widgets/markdown_description_field.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class AddEditScreen extends StatefulWidget {
  final Todo? todo;

  const AddEditScreen({super.key, this.todo});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  late Status status;
  RepeatFrequency repeat = RepeatFrequency.none;
  DateTime? repeatEndDate;
  DateTime? completedOn;
  DateTime? dueDate;
  Uint8List? imageBytes;
  String? initialImagePath;

  bool get isEdit => widget.todo != null;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    titleCtrl = TextEditingController(text: widget.todo?.title ?? '');
    descCtrl = TextEditingController(text: widget.todo?.description ?? '');
    status = widget.todo?.status ?? Status.inProgress;
    repeat = widget.todo?.repeat ?? RepeatFrequency.none;
    repeatEndDate = widget.todo?.repeatEndDate;
    completedOn = widget.todo?.completedOn;
    dueDate = widget.todo?.dueDate;
    initialImagePath = widget.todo?.imagePath;
    imageBytes = widget.todo?.imageBytes;
  }

  void _saveTodo() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    String title = titleCtrl.text.trim();
    String description = descCtrl.text.trim();

    if (title.isNotEmpty) {
      title = title.split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }

    if (description.isNotEmpty) {
      description = description[0].toUpperCase() + description.substring(1);
    }

    if (repeat == RepeatFrequency.none && repeatEndDate != null && dueDate == null) {
      dueDate = repeatEndDate;
    }

    if (dueDate == null && repeatEndDate != null && repeat != RepeatFrequency.none) {
      dueDate = DateUtils.dateOnly(DateTime.now()); 
    }

    final provider = context.read<TodoProvider>();

    if (isEdit) {
      provider.updateTodo(
        widget.todo!,
        title: title,
        description: description,
        status: status,
        repeat: repeat,
        repeatEndDate: repeatEndDate,
        imageBytes: imageBytes,
        dueDate: dueDate,
      );
    } else {
      provider.createAndAddTodo(
        title: title,
        description: description,
        status: status,
        repeat: repeat,
        repeatEndDate: repeatEndDate,
        imageBytes: imageBytes,
        dueDate: dueDate,
      );
    }

    Navigator.pop(context);
  }

  Future<void> _pickDate({
    required DateTime? initialValue,
    required DateTime firstDate,
    required Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialValue != null && !initialValue.isBefore(firstDate) 
          ? initialValue 
          : firstDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(icon, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  value == null
                      ? l10n.notSet
                      : DateFormat.yMMMd().format(value),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          if (value != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: onClear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateUtils.dateOnly(DateTime.now());
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.editTodo : l10n.addTodo),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: titleCtrl,
                              autofocus: !isEdit,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _saveTodo(),
                              expands: true,
                              maxLines: null,
                              minLines: null,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: Theme.of(context).textTheme.headlineSmall,
                              decoration: InputDecoration(
                                labelText: l10n.title,
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                contentPadding: const EdgeInsets.only(bottom: 8),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.emptyTitle : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (imageBytes != null || initialImagePath != null)
                            EditableImageField(
                              isEdit: true,
                              initialBytes: imageBytes,
                              initialImagePath: initialImagePath,
                              onChanged: (b) => setState(() => imageBytes = b),
                            )
                          else
                            ImagePickerField(onChanged: (b) => setState(() => imageBytes = b)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    MarkdownDescriptionField(
                      controller: descCtrl,
                      startWithPreview: isEdit,
                      todo: widget.todo,
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.schedule, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDateField(
                          label: l10n.dueDate,
                          value: dueDate,
                          icon: Icons.calendar_today,
                          onTap: () => _pickDate(
                            initialValue: dueDate,
                            firstDate: now,
                            onPicked: (d) => setState(() {
                              dueDate = d;
                              if (repeatEndDate != null && repeatEndDate!.isBefore(dueDate!)) {
                                repeatEndDate = dueDate;
                              }
                            }),
                          ),
                          onClear: () => setState(() => dueDate = null),
                        ),
                        const SizedBox(width: 8),
                        DropdownMenu<RepeatFrequency>(
                          width: 120,
                          label: Text(l10n.frequency),
                          initialSelection: repeat,
                          onSelected: (v) => setState(() => repeat = v!),
                          dropdownMenuEntries: RepeatFrequency.values
                              .map((r) => DropdownMenuEntry(value: r, label: r.localizedLabel(l10n)))
                              .toList(),
                        ),
                        const SizedBox(width: 8),
                        _buildDateField(
                          label: l10n.endDate,
                          value: repeatEndDate,
                          icon: Icons.event_available,
                          onTap: () => _pickDate(
                            initialValue: repeatEndDate,
                            firstDate: dueDate ?? now,
                            onPicked: (d) => setState(() => repeatEndDate = d),
                          ),
                          onClear: () => setState(() => repeatEndDate = null),
                        ),
                      ],
                    ),
                    if (isEdit) ...[
                      const SizedBox(height: 24),
                      Text(l10n.status, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: Status.values.map((s) => ChoiceChip(
                            label: Text(s.localizedLabel(l10n)),
                            selected: status == s,
                            showCheckmark: false,
                            onSelected: (_) => setState(() => status = s),
                          )).toList(),
                        ),
                      ),
                      if (status == Status.completed && completedOn != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${l10n.completedOnPrefix} ${DateFormat.yMMMd().add_jm().format(completedOn!)}',
                            style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: _saveTodo,
                  child: Text(isEdit ? l10n.update : l10n.save, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
