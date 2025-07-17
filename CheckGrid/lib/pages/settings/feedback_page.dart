import 'dart:io';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/components/photopicker.dart';
import 'package:checkgrid/components/textfield.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
    _feedbackController.dispose();
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

  Widget _buildFeedbackForm() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: TextField(
              controller: _feedbackController,
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
                  borderSide: BorderSide(width: 1.0, color: Colors.blue),
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
                      padding: EdgeInsets.all(5),
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
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16),
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
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: screenshotList.length,
        itemBuilder: (context, index) {
          final screenshot = screenshotList[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Image.file(
                  File(screenshot.path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        screenshotList.removeAt(index);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
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
          _selectedItems.updateAll((key, value) => false);
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
                    color: Colors.blue,
                  ),
                );
              },
            ),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: () {
        context.read<SettingsProvider>().doVibration(1);
        // Call API
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              const Spacer(),
              Text(
                "Submit feedback",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
      body: SafeArea(
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
                if (screenshots.isNotEmpty) _buildScreenshots(screenshots),
                SizedBox(height: 30),
                _buildEmailField(),
                SizedBox(height: 50),
                _buildSubmitButton(),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
