import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Effective date: January 2025',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context: context,
              title: '1. Acceptance of Terms',
              content: '''By accessing or using the Komiut application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.

These terms apply to all users of the app, including passengers, drivers, and SACCO operators.''',
            ),
            _buildSection(
              context: context,
              title: '2. Description of Service',
              content: '''Komiut provides a platform that connects passengers with public transport vehicles (matatus, buses) operated by registered SACCOs. We facilitate:

• Route discovery and booking
• Digital ticketing and payments
• Queue management
• Trip tracking
• Loyalty rewards

Komiut is a technology platform and does not operate transport vehicles directly.''',
            ),
            _buildSection(
              context: context,
              title: '3. User Accounts',
              content: '''To use our services, you must:

• Be at least 18 years old or have parental consent
• Provide accurate and complete registration information
• Maintain the security of your account credentials
• Notify us immediately of any unauthorized use

You are responsible for all activities under your account.''',
            ),
            _buildSection(
              context: context,
              title: '4. Booking and Payments',
              content: '''When you book a trip:

• You agree to pay the displayed fare
• Bookings are subject to vehicle availability
• Cancellation policies apply as displayed
• Refunds are processed per our refund policy

Payment processing is handled by secure third-party providers (M-Pesa). We do not store your payment credentials.''',
            ),
            _buildSection(
              context: context,
              title: '5. User Conduct',
              content: '''You agree not to:

• Provide false information
• Interfere with the app's operation
• Use the service for illegal purposes
• Harass drivers, passengers, or staff
• Attempt to circumvent security measures
• Resell or transfer bookings without authorization

Violation may result in account suspension or termination.''',
            ),
            _buildSection(
              context: context,
              title: '6. Limitation of Liability',
              content: '''Komiut is not liable for:

• Actions of SACCO operators or drivers
• Delays, cancellations, or service interruptions
• Personal injury during trips (covered by SACCO insurance)
• Loss of personal belongings
• Indirect or consequential damages

Our liability is limited to the amount you paid for the specific service.''',
            ),
            _buildSection(
              context: context,
              title: '7. Intellectual Property',
              content: '''All content, features, and functionality of the Komiut app are owned by Komiut and protected by intellectual property laws. You may not:

• Copy or modify the app
• Reverse engineer the software
• Use our trademarks without permission
• Scrape or collect data from the app''',
            ),
            _buildSection(
              context: context,
              title: '8. Termination',
              content: '''We may terminate or suspend your account at any time for violation of these terms. Upon termination:

• Your right to use the service ceases immediately
• Pending bookings may be cancelled
• Wallet balance will be refunded per our policy

You may also delete your account at any time through the app.''',
            ),
            _buildSection(
              context: context,
              title: '9. Dispute Resolution',
              content: '''Any disputes arising from these terms shall be:

• First attempted to be resolved through our support team
• Subject to mediation if direct resolution fails
• Governed by the laws of Kenya
• Subject to the jurisdiction of Kenyan courts''',
            ),
            _buildSection(
              context: context,
              title: '10. Changes to Terms',
              content: '''We reserve the right to modify these terms at any time. We will notify users of significant changes through the app or email. Continued use after changes constitutes acceptance of the new terms.''',
            ),
            _buildSection(
              context: context,
              title: '11. Contact',
              content: '''For questions about these terms, contact us:

Email: legal@komiut.com
Phone: +254 700 000 000
Address: Nairobi, Kenya''',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
