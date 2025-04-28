import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                style: TextStyle(fontSize: 13),
                children: [
                  TextSpan(text: "Last updated: "),
                  TextSpan(
                    text: "April 28, 2025\n\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "Welcome to our application. We are committed to protecting your personal information and your right to privacy. "
                        "If you have any questions or concerns about our policy or our practices regarding your personal information, "
                        "please contact us at support@example.com.\n\n",
                  ),
                  TextSpan(
                    text: "1. Information We Collect\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "- Personal Information you disclose to us (such as your name, email address, and other contact details).\n"
                        "- Information automatically collected, such as device data, IP address, operating system, browser type, "
                        "and usage details.\n\n",
                  ),
                  TextSpan(
                    text: "2. How We Use Your Information\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "- To provide, operate, and maintain our services.\n"
                        "- To improve, personalize, and expand our services.\n"
                        "- To communicate with you, either directly or through one of our partners, including for customer service, "
                        "to provide you with updates and other information.\n"
                        "- For analytics and research purposes to improve our offerings.\n"
                        "- To detect, prevent, and address technical issues and fraud.\n\n",
                  ),
                  TextSpan(
                    text: "3. Sharing Your Information\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "- We do not sell, trade, rent or share your information with third parties for marketing purposes.\n"
                        "- We may share your information with trusted service providers who work on our behalf, under strict confidentiality agreements.\n"
                        "- We may disclose your information where required to do so by law or to protect our legal rights.\n\n",
                  ),
                  TextSpan(
                    text: "4. Data Security\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "- We have implemented appropriate technical and organizational security measures designed to protect the security "
                        "of any personal information we process.\n"
                        "- However, despite our safeguards and efforts to secure your information, no electronic transmission over the Internet "
                        "or information storage technology can be guaranteed to be 100% secure.\n\n",
                  ),
                  TextSpan(
                    text: "5. Your Privacy Rights\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "- You have the right to access, correct, update or request deletion of your personal information.\n"
                        "- You may object to the processing of your personal information, ask us to restrict processing, or request portability of your information.\n"
                        "- If we have collected and process your personal information with your consent, you can withdraw your consent at any time.\n\n",
                  ),
                  TextSpan(
                    text: "6. Children's Privacy\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "- Our services are not directed to individuals under the age of 13. We do not knowingly collect personal information from children.\n\n",
                  ),
                  TextSpan(
                    text: "7. Changes to This Privacy Policy\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "- We may update this privacy policy from time to time. We will notify you of any changes by posting the new Privacy Policy in this app.\n"
                        "- You are advised to review this Privacy Policy periodically for any changes.\n\n",
                  ),
                  TextSpan(
                    text: "8. Contact Us\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "If you have any questions about this Privacy Policy, you can contact us by email: support@example.com\n\n"
                        "Thank you for trusting us.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
