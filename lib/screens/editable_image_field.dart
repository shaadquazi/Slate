import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slate/widgets/image_picker_field.dart';

class EditableImageField extends StatefulWidget {
  final bool isEdit;
  final Uint8List? initialBytes;

  const EditableImageField({
    super.key,
    this.initialBytes,
    required this.isEdit,
  });

  @override
  State<EditableImageField> createState() => _EditableImageFieldState();
}

class _EditableImageFieldState extends State<EditableImageField> {
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    imageBytes = widget.initialBytes;
  }

  // Pick image from gallery
  Future<Uint8List?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      return await file.readAsBytes();
    }
    return null;
  }

  // Fullscreen image viewer
  void showImagePopup(BuildContext context, Uint8List bytes) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87, // dark background
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Center(child: _ZoomableImage(bytes: bytes)),
                  Positioned(
                    top: 5,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageBytes == null && widget.isEdit) {
      return ImagePickerField(
        initialBytes: imageBytes,
        onChanged: (b) {
          setState(() => imageBytes = b);
        },
      );
    }

    if (imageBytes != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text('Photo', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => showImagePopup(context, imageBytes!),
                    child: Image.memory(
                      imageBytes!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (widget.isEdit)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final newBytes = await pickImage();
                          if (newBytes != null) {
                            setState(() => imageBytes = newBytes);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }
}

class _ZoomableImage extends StatefulWidget {
  final Uint8List bytes;
  const _ZoomableImage({required this.bytes});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  late TransformationController _controller;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final position = _doubleTapDetails!.localPosition;
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity(); // reset zoom
    } else {
      _controller.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(2.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        panEnabled: true,
        minScale: 1,
        maxScale: 4,
        child: Image.memory(widget.bytes),
      ),
    );
  }
}
