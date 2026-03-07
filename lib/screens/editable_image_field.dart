import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

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
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: 0.9),
                  builder: (_) => _ImageZoomDialog(
                    imageBytes: _bytes ?? widget.initialBytes,
                    imagePath: widget.initialImagePath,
                  ),
                );
              },
              child: imageWidget,
            ),
            if (widget.isEdit)
              Positioned(
                top: 4,
                right: 4,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        iconSize: 16,
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _showPickerOptions(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        iconSize: 16,
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

class _ImageZoomDialog extends StatefulWidget {
  final Uint8List? imageBytes;
  final String? imagePath;

  const _ImageZoomDialog({this.imageBytes, this.imagePath});

  @override
  State<_ImageZoomDialog> createState() => _ImageZoomDialogState();
}

class _ImageZoomDialogState extends State<_ImageZoomDialog> {
  final _transformationController = TransformationController();
  bool _showIndicator = false;
  Timer? _hideTimer;
  int _zoomPercentage = 100;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onTransformationChanged() {
    final zoom = _transformationController.value.getMaxScaleOnAxis() * 100;
    final newPercentage = zoom.round();

    if (newPercentage != _zoomPercentage) {
      setState(() {
        _zoomPercentage = newPercentage;
        _showIndicator = true;
      });

      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showIndicator = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Stack(
        children: [
          GestureDetector(
            onDoubleTap: () {
              if (_transformationController.value != Matrix4.identity()) {
                _transformationController.value = Matrix4.identity();
              } else {
                _transformationController.value = Matrix4.diagonal3Values(3, 3, 1);
              }
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 4.0,
              child: widget.imageBytes != null
                  ? Image.memory(widget.imageBytes!)
                  : widget.imagePath != null
                      ? Image.file(File(widget.imagePath!))
                      : const SizedBox.shrink(),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (_showIndicator)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_zoomPercentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
