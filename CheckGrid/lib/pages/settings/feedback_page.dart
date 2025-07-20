import 'dart:io';

import 'package:checkgrid/components/test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/components/photopicker.dart';
import 'package:checkgrid/components/textfield.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

// Can be cleaned up with screenshot and screenshotlist by sending in index instead of screenshot directly

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  XFile? userScreenshot;
  List<XFile> screenshots = [];

  final Map<String, bool> _selectedItems = {
    "Report a Bug": false,
    "Performance Issues": false,
    "UI/UX Problems": false,
    "In-App Purchase Issues": false,
    "Feature Suggestion": false,
    "Other": false,
  };

  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, Animation<double>> _scaleAnimations = {};
  bool _showEmailError = false; // Lägg till denna variabel

  @override
  void initState() {
    super.initState();
    for (var title in _selectedItems.keys) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
      _animationControllers[title] = controller;
      _scaleAnimations[title] = Tween<double>(
        begin: 1.0,
        end: 1.5,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    // Dispose all animation controllers
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildEmailField() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputFieldOutsideApp(
            labelText: "Email*",
            hintText: "Enter your email address",
            icon: Icons.email_outlined,
            fontSize: 16.0,
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
            controller: _emailController,
            showError: _showEmailError, // Skicka med showError parameter
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: () {
        // Validera email vid submit
        setState(() {
          _showEmailError = true;
        });

        // Kontrollera om email är valid
        final emailError = _validateEmail(_emailController.text);
        if (emailError == null) {
          // Email är valid, fortsätt med submit
          // Här kan du lägga till din API-kod
          debugPrint("Email is valid, submitting...");

          // Eventuellt återställ error state efter lyckad submit
          setState(() {
            _showEmailError = false;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Row(
            children: [
              const Spacer(),
              Text(
                "Submit feedback",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // Hjälpmetod för email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Widget _buildFeedbackForm() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 300,
            child: TextField(
              selectionControls:
              // IOS
              CustomColorSelectionHandle(
                handleColor: CupertinoColors.systemBlue,
                toolbarColor: CupertinoColors.systemBlue,
                cursorColor: CupertinoColors.systemBlue,
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              decoration: InputDecoration(
                hintText: "Please briefly describe the issue",
                hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.0,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap:
                () => PhotoPicker.pickImages(context, screenshots, (list) {
                  setState(() {
                    screenshots = list;
                  });
                }),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 84, 84, 84),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: EdgeInsetsGeometry.all(5),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  const Text(
                    "Upload screenshots (optional)",
                    style: TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshots(List<XFile> screenshotList) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: screenshotList.length,
        itemBuilder: (context, index) {
          final screenshot = screenshotList[index];
          return _ShrinkableImage(
            key: ValueKey(screenshot.path),
            screenshot: screenshot,
            screenshotList: screenshotList,
            onRemove: () {
              setState(() {
                screenshotList.removeAt(index);
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCheckItem(String title) {
    bool isSelected = _selectedItems[title] ?? false;
    final animationController = _animationControllers[title];
    final scaleAnimation = _scaleAnimations[title];

    return GestureDetector(
      onTap: () {
        setState(() {
          // Set all items to false
          _selectedItems.updateAll((key, value) => false);
          // Set the tapped item to true
          _selectedItems[title] = true;
          if (animationController != null) {
            animationController.forward().then(
              (_) => animationController.reverse(),
            );
          }
        });
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: scaleAnimation ?? AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                return Transform.scale(
                  scale: scaleAnimation?.value ?? 1.0,
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: CupertinoColors.systemBlue,
                  ),
                );
              },
            ),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feedback", style: TextStyle(fontSize: 20)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Hide keyboard
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Please select the type of feedback:",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  _buildCheckItem("Report a Bug"),
                  _buildCheckItem("Performance Issues"),
                  _buildCheckItem("UI/UX Problems"),
                  _buildCheckItem("In-App Purchase Issues"),
                  _buildCheckItem("Feature Suggestion"),
                  _buildCheckItem("Other"),
                  SizedBox(height: 30),
                  _buildFeedbackForm(),
                  SizedBox(height: 30),
                  if (screenshots.isNotEmpty) ...[
                    _buildScreenshots(screenshots),
                    SizedBox(height: 30),
                  ],
                  _buildEmailField(),
                  SizedBox(height: 50),
                  _buildSubmitButton(),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Animation for images being removed

class _ShrinkableImage extends StatefulWidget {
  final List<XFile> screenshotList;
  final XFile screenshot;
  final VoidCallback onRemove;

  const _ShrinkableImage({
    super.key,
    required this.screenshotList,
    required this.screenshot,
    required this.onRemove,
  });

  @override
  _ShrinkableImageState createState() => _ShrinkableImageState();
}

class _ShrinkableImageState extends State<_ShrinkableImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRemove();
      }
    });
  }

  void _startRemove() {
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _buildPreview(List<XFile> screenshotList, int startIndex) {
    showDialog(
      context: context,
      builder: (context) {
        int currentIndex = startIndex;

        return StatefulBuilder(
          builder: (context, setState) {
            // Loop runt
            if (currentIndex >= screenshotList.length) currentIndex = 0;
            if (currentIndex < 0) currentIndex = screenshotList.length - 1;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 400,
                    height: 600,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.black,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(screenshotList[currentIndex].path),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // X-icon
                  Positioned(
                    top: -10,
                    right: -10,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(164, 158, 158, 158),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (screenshotList.length > 1) ...[
                    // Right arrow
                    Positioned(
                      top: (600 - 30) / 2,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            currentIndex++;
                            if (currentIndex >= screenshotList.length) {
                              currentIndex = 0;
                            }
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(163, 100, 100, 100),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Left arrow
                    Positioned(
                      top: (600 - 30) / 2,
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            currentIndex--;
                            if (currentIndex < 0) {
                              currentIndex = screenshotList.length - 1;
                            }
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(163, 100, 100, 100),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        // Lägg till padding för att ge plats åt remove-ikonen
        margin: const EdgeInsets.all(8.0),

        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Image
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: GestureDetector(
                onTap:
                    () => _buildPreview(
                      widget.screenshotList,
                      widget.screenshotList.indexOf(widget.screenshot),
                    ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.screenshot.path),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Remove icon
            Positioned(
              top: -5,
              right: -5,
              child: GestureDetector(
                onTap: _startRemove,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(163, 114, 114, 114),
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
