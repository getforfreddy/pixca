import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''Pixca Privacy Policy
Effective Date: [Insert Date]

1. Introduction

Welcome to Pixca. We value your privacy and are committed to protecting your personal data. This Privacy Policy outlines our practices regarding the collection, use, and disclosure of your information when you use our website, mobile applications, and other online products and services (collectively, the "Services").

2. Information We Collect

We collect the following types of information:

a. Personal Information:

Contact Information: Name, email address, phone number, and mailing address.
Account Information: Username, password, and profile details.
b. Usage Data:

Information about how you use our Services, including the types of content you interact with, the frequency and duration of your activities, and your preferences.
c. Device Information:

Information about the device you use to access our Services, including IP address, browser type, operating system, and mobile device identifiers.
d. Location Data:

Approximate location information based on your IP address or mobile device settings.
3. How We Use Your Information

We use the collected information for the following purposes:

To provide, maintain, and improve our Services.
To personalize your experience and tailor the content and advertisements you see.
To communicate with you, including sending updates, security alerts, and support messages.
To monitor and analyze trends, usage, and activities in connection with our Services.
To detect, investigate, and prevent fraudulent transactions and other illegal activities.
To comply with legal obligations and enforce our terms and policies.
4. Sharing Your Information

We do not share your personal information with third parties except in the following circumstances:

With your consent: We may share your information with third parties if you give us permission.
Service Providers: We may share your information with third-party vendors and service providers who perform services on our behalf.
Legal Requirements: We may disclose your information if required by law or in response to a legal process.
Business Transfers: In the event of a merger, acquisition, or sale of assets, your information may be transferred to the new owner.
5. Your Choices

You have the following rights regarding your personal information:

Access: You can request access to the personal information we hold about you.
Correction: You can request that we correct or update your personal information.
Deletion: You can request that we delete your personal information.
Opt-Out: You can opt-out of receiving promotional communications from us by following the instructions in those communications.
6. Security

We take reasonable measures to protect your personal information from unauthorized access, use, or disclosure. However, no security system is impenetrable, and we cannot guarantee the security of our systems 100%.

7. Children's Privacy

Our Services are not directed to children under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that we have collected personal information from a child under 13, we will take steps to delete such information.

8. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on our website and updating the effective date. Your continued use of our Services after the changes take effect constitutes your acceptance of the revised Privacy Policy.

9. Contact Us

If you have any questions about this Privacy Policy, please contact us at:

Email: Freddy Nixal Nixon
Address: freddynixal1999@gmail.com
            ''',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}