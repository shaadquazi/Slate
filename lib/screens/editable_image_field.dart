import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slate/l10n/generated/app_localizations.dart';
import 'package:slate/widgets/image_picker_field.dart';

class EditableImageField extends StatefulWidget {
  final bool isEdit;
  final Uint8List? initialBytes;
  final String? initialImagePath;
  final ValueChanged<Uint8List?> onChanged;

  const EditableImageField({
    super.key,
    required this.isEdit,
    this.initialBytes,
    this.initialImagePath,
    required this.onChanged,
  });

  @override
  State<EditableImageField> createState() => _EditableImageFieldState();
}

class _EditableImageFieldState extends State<EditableImageField> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = widget.initialBytes;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _bytes = bytes);
      widget.onChanged(bytes);
    }
  }

  void _removeImage() {
    setState(() => _bytes = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    Widget? imageWidget;
    if (_bytes != null) {
      imageWidget = Image.memory(_bytes!, fit: BoxFit.cover);
    } else if (widget.initialImagePath != null) {
      imageWidget = Image.file(File(widget.initialImagePath!), fit: BoxFit.cover);
    } else if (widget.initialBytes != null) {
      imageWidget = Image.memory(widget.initialBytes!, fit: BoxFit.cover);
    }

    if (imageWidget == null) {
      return ImagePickerField(onChanged: (b) {
        setState(() => _bytes = b);
        widget.onChanged(b);
      });
    }

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    insetPadding: EdgeInsets.zero,
                    child: Stack(
                      children: [
                        InteractiveViewer(
                          child: _bytes != null
                              ? Image.memory(_bytes!)
                              : widget.initialImagePath != null
                                  ? Image.file(File(widget.initialImagePath!))
                                  : widget.initialBytes != null
                                      ? Image.memory(widget.initialBytes!)
                                      : const SizedBox.shrink(),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: imageWidget,
            ),
            if (widget.isEdit)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _showPickerOptions(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: _removeImage,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.gallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.camera),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
