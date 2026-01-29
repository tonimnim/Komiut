import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/shared/widgets/komiut_app_bar.dart';

class PrivacyTermsScreen extends StatelessWidget {
  final bool isPrivacy;

  const PrivacyTermsScreen({super.key, this.isPrivacy = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: KomiutAppBar(
        title: isPrivacy ? 'Privacy Policy' : 'Terms of Service',
        showProfileIcon: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPrivacy ? 'Komiut Privacy Policy' : 'Terms and Conditions',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: January 15, 2026',
              style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            _buildParagraph(
              '1. Introduction',
              'Welcome to Komiut. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about this privacy notice, or our practices with regards to your personal information, please contact us.',
              theme,
            ),
            _buildParagraph(
              '2. Data Collection',
              'We collect personal information that you voluntarily provide to us when you register on the App, express an interest in obtaining information about us or our products and Services, when you participate in activities on the App or otherwise when you contact us.',
              theme,
            ),
            _buildParagraph(
              '3. Location Data',
              'We may request access or permission to and track location-based information from your mobile device, either continuously or while you are using the App, to provide certain location-based services.',
              theme,
            ),
            _buildParagraph(
              '4. Shared Information',
              'We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations.',
              theme,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String title, String content, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          content,
          style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurface, height: 1.6),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

