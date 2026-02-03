import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: January 2025',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context: context,
              title: '1. Information We Collect',
              content:
                  '''We collect information you provide directly to us, including:

• Personal information (name, email, phone number)
• Payment information (processed securely via M-Pesa)
• Location data (to show nearby routes and track trips)
• Device information (for app optimization)
• Usage data (to improve our services)''',
            ),
            _buildSection(
              context: context,
              title: '2. How We Use Your Information',
              content: '''We use the information we collect to:

• Provide, maintain, and improve our services
• Process transactions and send related information
• Send notifications about trips, queue status, and promotions
• Monitor and analyze trends and usage
• Detect, investigate, and prevent fraudulent transactions
• Personalize your experience''',
            ),
            _buildSection(
              context: context,
              title: '3. Information Sharing',
              content: '''We may share your information with:

• SACCO operators and drivers (limited to trip-related info)
• Payment processors (M-Pesa/Safaricom)
• Service providers who assist our operations
• Law enforcement when required by law

We do not sell your personal information to third parties.''',
            ),
            _buildSection(
              context: context,
              title: '4. Data Security',
              content:
                  '''We implement appropriate security measures to protect your data:

• Encryption of sensitive data in transit and at rest
• Secure payment processing through trusted providers
• Regular security audits and monitoring
• Access controls and authentication

However, no method of transmission over the Internet is 100% secure.''',
            ),
            _buildSection(
              context: context,
              title: '5. Your Rights',
              content: '''You have the right to:

• Access your personal information
• Correct inaccurate data
• Delete your account and data
• Opt-out of promotional communications
• Export your data

To exercise these rights, contact us at privacy@komiut.com''',
            ),
            _buildSection(
              context: context,
              title: '6. Location Data',
              content: '''We collect location data to:

• Show routes near you
• Track active trips for safety
• Provide ETA estimates
• Enable emergency assistance

You can disable location access in your device settings, but some features may not work properly.''',
            ),
            _buildSection(
              context: context,
              title: '7. Data Retention',
              content:
                  '''We retain your data for as long as your account is active or as needed to provide services. Trip history is retained for 2 years for dispute resolution. You can request deletion of your account at any time.''',
            ),
            _buildSection(
              context: context,
              title: '8. Changes to This Policy',
              content:
                  '''We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date.''',
            ),
            _buildSection(
              context: context,
              title: '9. Contact Us',
              content:
                  '''If you have questions about this privacy policy, please contact us:

Email: privacy@komiut.com
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
