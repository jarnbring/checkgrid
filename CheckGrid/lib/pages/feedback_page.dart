import 'package:flutter/material.dart';
import 'package:CheckGrid/components/photopicker.dart';
import 'package:CheckGrid/components/textfield.dart';
import 'package:CheckGrid/providers/general_provider.dart';
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

  final Map<String, bool> _selectedItems = {
    "Report a Bug": false,
    "Performance Issues": false,
    "UI/UX Problems": false,
    "In-App Purchase Issues": false,
    "Feature Suggestion": false,
    "Other": false,
  };

  // Animation controllers för varje check item
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, Animation<double>> _scaleAnimations = {};

  @override
  void initState() {
    super.initState();
    // Initiera animation controllers för varje item
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
    // Disposa animation controllers
    _animationControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Widget _buildEmailField() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputFieldOutsideApp(
            labelText: "Email",
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
                hintStyle: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 1.0, color: Colors.black),
                ),
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.all(screenWidth * 0.02),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => {print("HEJ")},
            child: Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(width: 1.0, color: Colors.grey)),
              ),
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Row(
                children: [
                  PhotoPicker(
                    onImagePicked: (XFile? image) {
                      setState(() {
                        userScreenshot = image;
                      });
                    },
                    radius: 300.0,
                  ),
                  SizedBox(width: screenWidth * 0.025),
                  Text(
                    "Upload screenshot (optional)",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: screenWidth * 0.035,
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

  Widget buildCheckItem(String title, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.04),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.blue),
          SizedBox(width: screenWidth * 0.025),
        ],
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
                SizedBox(height: adjustedScreenHeight * 0.03),
                _buildFeedbackForm(screenWidth, adjustedScreenHeight),
                SizedBox(height: adjustedScreenHeight * 0.1),
                _buildEmailField(),
                SizedBox(height: adjustedScreenHeight * 0.1),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            print(
                              "Feedback submitted: ${_emailController.text}",
                            );
                          }
                        },
                        child: Text(
                          "Submit",
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: adjustedScreenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: const BannerAdWidget(),
    );
  }
}
