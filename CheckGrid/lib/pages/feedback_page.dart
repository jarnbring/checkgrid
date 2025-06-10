import 'dart:io';

import 'package:flutter/material.dart';
import 'package:checkgrid/components/photopicker.dart';
import 'package:checkgrid/components/textfield.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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

  Widget _buildFeedbackForm(double screenWidth, double adjustedScreenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: adjustedScreenHeight * 0.25, // Begränsad höjd för TextField
            child: TextField(
              maxLines: null, // Låter TextField växa inom SizedBox
              expands: true, // Fyller tillgänglig höjd
              textAlignVertical: TextAlignVertical.top, // Text börjar högst upp
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
                      color: Colors.blueAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
    // Add an animation that plays when the user removes an image.
    // Add the option to press an image and show a preview.
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: screenshotList.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(screenshotList[index].path),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
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
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(164, 158, 158, 158),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckItem(String title, double screenWidth) {
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
        padding: EdgeInsets.only(bottom: screenWidth * 0.04),
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
            SizedBox(width: screenWidth * 0.025),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: screenWidth * 0.04,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final screenWidth = generalProvider.getScreenWidth(context);
    final screenHeight = generalProvider.getScreenHeight(context);
    final bannerAdHeight = generalProvider.getBannerAdHeight();
    final adjustedScreenHeight = screenHeight - bannerAdHeight;

    return Scaffold(
      appBar: AppBar(
        title: Text("Feedback", style: TextStyle(fontSize: screenWidth * 0.05)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: adjustedScreenHeight * 0.02),
                Text(
                  "Please select the type of feedback:",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                SizedBox(height: adjustedScreenHeight * 0.02),
                _buildCheckItem("Report a Bug", screenWidth),
                _buildCheckItem("Performance Issues", screenWidth),
                _buildCheckItem("UI/UX Problems", screenWidth),
                _buildCheckItem("In-App Purchase Issues", screenWidth),
                _buildCheckItem("Feature Suggestion", screenWidth),
                _buildCheckItem("Other", screenWidth),
                SizedBox(height: 30),
                _buildFeedbackForm(screenWidth, adjustedScreenHeight),
                SizedBox(height: adjustedScreenHeight * 0.03),
                if (screenshots.isNotEmpty) _buildScreenshots(screenshots),
                SizedBox(height: adjustedScreenHeight * 0.03),
                _buildEmailField(),
                SizedBox(height: 50),
                GestureDetector(
                  onTap: () => {},
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: adjustedScreenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
