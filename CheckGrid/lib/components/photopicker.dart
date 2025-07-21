import 'package:checkgrid/providers/error_service.dart';
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
          (file) => !existingPaths.contains(file.path),
        );
        final updated = List<XFile>.from(existing)..addAll(newFiles);
        onImagesPicked(updated);
      }
    } catch (e) {
      if (!context.mounted) return;
      ErrorService().showError(
        context,
        "Something went wrong while picking image. Please try again later.",
        useTopPosition: true,
      );
      ErrorService().logError(e, StackTrace.current);
    }
  }
}
