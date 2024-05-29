import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms and Conditions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''Terms and Conditions

1. Introduction
Welcome to Spectrum softSolution. These Terms and Conditions ("Terms", "Terms and Conditions") govern your relationship with [Your Website] (the "Service") operated by Spectrum softSolution.

By accessing and using the Service, you agree to comply with and be bound by these Terms. If you disagree with any part of the terms, you may not access the Service.

2. Accounts
When you create an account with us, you must provide accurate, complete, and current information. Failure to do so constitutes a breach of the Terms, which may result in the immediate termination of your account.

You are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password.

3. Intellectual Property
The Service and its original content, features, and functionality are and will remain the exclusive property of Spectrum softSolution and its licensors. The Service is protected by copyright, trademark, and other laws of both the India and foreign countries.

4. Links to Other Websites
Our Service may contain links to third-party websites or services that are not owned or controlled by Spectrum softSolution. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party websites or services.

5. Termination
We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.

Upon termination, your right to use the Service will cease immediately.

6. Limitation of Liability
In no event shall Spectrum softSolution, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from 
(i) your use of or inability to use the Service; 
(ii) any unauthorized access to or use of our servers and/or any personal information stored therein; 
(iii) any interruption or cessation of transmission to or from the Service; 
(iv) any bugs, viruses, trojan horses, or the like that may be transmitted to or through our Service by any third party; and/or 
(v) any errors or omissions in any content or for any loss or damage incurred as a result of the use of any content posted, emailed, transmitted, or otherwise made available through the Service.

7. Disclaimer
Your use of the Service is at your sole risk. The Service is provided on an "AS IS" and "AS AVAILABLE" basis. The Service is provided without warranties of any kind, whether express or implied, including but not limited to, implied warranties of merchantability, fitness for a particular purpose, non-infringement, or course of performance.

8. Governing Law
These Terms shall be governed and construed in accordance with the laws of India, without regard to its conflict of law provisions.

9. Changes
We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days' notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.

By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms. If you do not agree to the new terms, please stop using the Service.

10. Contact Us
If you have any questions about these Terms, please contact us at freddynixal1999@gmail.com.
            ''',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}