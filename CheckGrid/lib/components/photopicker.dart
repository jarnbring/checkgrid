import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPicker extends StatefulWidget {
  final Function(XFile?) onImagePicked; 
  final double radius;

  const PhotoPicker({super.key, required this.onImagePicked, required this.radius});

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  bool isTapped = true;
  XFile? _pickedFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
          isTapped = false;
        });
        widget.onImagePicked(pickedFile); 
      }
    } catch (e) {
      // Handle errors
    }
  }

  XFile? getPickedImage() {
    if (_pickedFile != null) {
    return _pickedFile;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: isTapped
          ? Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(widget.radius * 0.02),
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  )
          : _pickedFile != null
              ? CircleAvatar(
                  radius: widget.radius,
                  backgroundImage: FileImage(File(_pickedFile!.path)),
                )
              :  CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: widget.radius,
                  child: Text("No image"),
                ),
    );
  }
}
