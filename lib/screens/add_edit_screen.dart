import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:slate/screens/editable_image_field.dart';
import 'package:slate/widgets/image_picker_field.dart';

import 'package:image_picker/image_picker.dart';
import 'package:slate/widgets/optional_description_field.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../constants/app_strings.dart';

class AddEditScreen extends StatefulWidget {
  final Todo? todo; // null = add, not null = edit

  const AddEditScreen({super.key, this.todo});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  late Status status;
  // late RepeatFrequency repeat;
  bool repeatEnabled = false;
  RepeatFrequency repeat = RepeatFrequency.daily;
  DateTime? repeatEndDate;
  DateTime? completedOn;
  Uint8List? imageBytes;

  bool get isEdit => widget.todo != null;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    titleCtrl = TextEditingController(text: widget.todo?.title ?? '');
    descCtrl = TextEditingController(text: widget.todo?.description ?? '');
    status = widget.todo?.status ?? Status.inProgress;
    repeatEnabled =
        (widget.todo?.repeat ?? RepeatFrequency.none) != RepeatFrequency.none;
    repeat = widget.todo?.repeat ?? RepeatFrequency.none;
    repeatEndDate = widget.todo?.repeatEndDate;
    completedOn = widget.todo?.completedOn;
    imageBytes = widget.todo?.imageBytes;
  }

  void _saveTodo() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TodoProvider>();

    if (isEdit) {
      provider.updateTodo(
        todo: widget.todo!,
        title: titleCtrl.text,
        description: descCtrl.text,
        status: status,
        repeat: repeat,
        repeatEndDate: repeatEndDate,
        imageBytes: imageBytes,
      );
    } else {
      provider.addTodo(
        Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: titleCtrl.text,
          description: descCtrl.text,
          status: status,
          repeat: repeatEnabled ? repeat : RepeatFrequency.none,
          repeatEndDate: repeatEnabled ? repeatEndDate : null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          imageBytes: imageBytes,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? AppStrings.editTodo : AppStrings.addTodo),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  autofocus: !isEdit,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _saveTodo(),
                  decoration: const InputDecoration(
                    labelText: LabelStrings.title,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return MsgStrings.emptyTitle;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                OptionalDescriptionField(controller: descCtrl),
                const SizedBox(height: 16),
                if (imageBytes == null) ...[
                  ImagePickerField(
                    initialBytes: imageBytes,
                    onChanged: (b) {
                      setState(() => imageBytes = b);
                    },
                  ),
                ],
                if (imageBytes != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Photo',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        EditableImageField(
                          isEdit: isEdit ? true : imageBytes != null,
                          initialBytes: imageBytes,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Repeat',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      value: repeatEnabled,
                      onChanged: (v) {
                        setState(() {
                          repeatEnabled = v;

                          if (!v) {
                            repeat = RepeatFrequency.none;
                            repeatEndDate = null;
                          }
                        });
                      },
                    ),
                    if (repeatEnabled) ...[
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          /// Frequency dropdown
                          Expanded(
                            child: DropdownMenu<RepeatFrequency>(
                              label: const Text('Frequency'),
                              initialSelection: repeat,
                              onSelected: (v) => setState(() => repeat = v!),
                              dropdownMenuEntries: RepeatFrequency.values
                                  .where((r) => r != RepeatFrequency.none)
                                  .map(
                                    (r) => DropdownMenuEntry(
                                      value: r,
                                      label: r.label,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// End date picker
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: repeatEndDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );

                                if (picked != null) {
                                  setState(() => repeatEndDate = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'End date',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  repeatEndDate == null
                                      ? 'No end date'
                                      : DateFormat.yMMMd().format(
                                          repeatEndDate!,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                if (isEdit) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: Status.values.map((s) {
                            final selected = status == s;
                            return ChoiceChip(
                              label: Text(s.label),
                              selected: selected,
                              showCheckmark: false,
                              selectedColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              onSelected: (_) => setState(() => status = s),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (status == Status.completed && completedOn != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Completed on ${DateFormat.yMMMd().add_jm().format(completedOn!)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // aligns children to the right
                  children: [
                    ElevatedButton(
                      onPressed: _saveTodo,
                      child: Text(isEdit ? BtnStrings.update : BtnStrings.save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Function to pick an image and return bytes
Future<Uint8List?> pickImage() async {
  final ImagePicker picker = ImagePicker();
  // Pick an image from the gallery
  final XFile? file = await picker.pickImage(source: ImageSource.gallery);
  if (file != null) {
    return await file.readAsBytes(); // return image as Uint8List
  }
  return null;
}
