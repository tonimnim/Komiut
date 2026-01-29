/// Sacco Contact Card - Contact information widget.
///
/// Displays contact information for a Sacco including phone, email, and website.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import 'sacco_info_row.dart';

/// A card widget displaying Sacco contact information.
///
/// Shows phone number, email, and website with tappable actions.
/// Displays "Not available" message if no contact info is provided.
///
/// ```dart
/// SaccoContactCard(
///   phone: '+254 700 000 000',
///   email: 'info@sacco.co.ke',
///   website: 'https://sacco.co.ke',
/// )
/// ```
class SaccoContactCard extends StatelessWidget {
  /// Creates a SaccoContactCard.
  const SaccoContactCard({
    super.key,
    this.phone,
    this.email,
    this.website,
  });

  /// Phone number.
  final String? phone;

  /// Email address.
  final String? email;

  /// Website URL.
  final String? website;

  /// Whether any contact information is available.
  bool get _hasContactInfo =>
      phone != null || email != null || website != null;

  void _onPhoneTap(BuildContext context) {
    // TODO: Implement phone call using url_launcher
    // final uri = Uri.parse('tel:$phone');
    // launchUrl(uri);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phone...'),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onEmailTap(BuildContext context) {
    // TODO: Implement email using url_launcher
    // final uri = Uri.parse('mailto:$email');
    // launchUrl(uri);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening email to $email...'),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onWebsiteTap(BuildContext context) {
    // TODO: Implement website launch using url_launcher
    // final uri = Uri.parse(website!);
    // launchUrl(uri, mode: LaunchMode.externalApplication);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $website...'),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_hasContactInfo) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 20,
              color: isDark ? Colors.grey[500] : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Contact information not available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[500] : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (phone != null)
            SaccoInfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: phone!,
              iconColor: AppColors.primaryGreen,
              onTap: () => _onPhoneTap(context),
            ),
          if (phone != null && (email != null || website != null))
            Divider(
              height: 1,
              indent: 68,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
          if (email != null)
            SaccoInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email!,
              iconColor: AppColors.primaryBlue,
              onTap: () => _onEmailTap(context),
            ),
          if (email != null && website != null)
            Divider(
              height: 1,
              indent: 68,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
          if (website != null)
            SaccoInfoRow(
              icon: Icons.language,
              label: 'Website',
              value: website!,
              iconColor: AppColors.secondaryOrange,
              onTap: () => _onWebsiteTap(context),
            ),
        ],
      ),
    );
  }
}
