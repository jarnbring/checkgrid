import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildNumberField() {
    return TextField(
      keyboardType: TextInputType.numberWithOptions(),
      style: TextStyle(color: Colors.grey),
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1.0, color: Colors.black),
        ),
        contentPadding: EdgeInsets.all(0.0),
        prefix: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(width: 1.0, color: Colors.grey),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 10.0),
                  Text(
                    "+91",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.blue),
                  SizedBox(width: 10.0),
                ],
              ),
            ),
            SizedBox(width: 10.0),
          ],
        ),
      ),
    );
  }

  Widget buildFeedbackForm() {
    return Container(
      height: 200,
      child: Stack(
        children: [
          TextField(
            maxLines: 10,
            decoration: InputDecoration(
              hintText: "Please briefly describe the issue",
              hintStyle: TextStyle(fontSize: 13.0, color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 3.0, color: Colors.black),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 1.0, color: Colors.grey)),
              ),
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.add, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Upload screenshot (optional)",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCheckItem(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blue),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                "Please select the type of feedback:",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 30),
              buildCheckItem("Report a Bug"),
              buildCheckItem("Performance Issues"),
              buildCheckItem("UI/UX Problems"),
              buildCheckItem("In-App Purchase Issues"),
              buildCheckItem("Feature Suggestion"),
              SizedBox(height: 30),
              buildFeedbackForm(),
              SizedBox(height: 30),
              buildNumberField(),
              SizedBox(height: 100,),
              Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => {},
                  child: Text("Submit"),
                ),
              ),
            ],
      ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
