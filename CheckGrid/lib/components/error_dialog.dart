import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: const Text('Failed to Load'),
        content: const Text(
          'An error occurred while loading the game. Would you like to create a new board instead?\n\nNote: This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            isDefaultAction: true,
            child: const Text(
              'Cancel',
              style: TextStyle(color: CupertinoColors.activeBlue),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Create New',
              style: TextStyle(color: CupertinoColors.activeBlue),
            ),
          ),
        ],
      );
    } else {
      return AlertDialog(
        title: const Text('Failed to Load'),
        content: const Text(
          'It took too long to load the game. Do you want to create a new board instead?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create New'),
          ),
        ],
      );
    }
  }
}
