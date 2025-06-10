import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPicker {
  static final ImagePicker _picker = ImagePicker();

  static Future<void> pickImages(
    BuildContext context,
    List<XFile> existing,
    Function(List<XFile>) onImagesPicked,
  ) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final existingPaths = existing.map((e) => e.path).toSet();
        final newFiles = pickedFiles.where(
          (f) => !existingPaths.contains(f.path),
        );
        final updated = List<XFile>.from(existing)..addAll(newFiles);
        onImagesPicked(updated);
      }
    } catch (e) {
      debugPrint("Could not pick images: $e");
    }
  }
}
