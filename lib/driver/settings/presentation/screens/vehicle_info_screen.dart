import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut/shared/widgets/komiut_app_bar.dart';

class VehicleInfoScreen extends StatelessWidget {
  final Vehicle? vehicle;

  const VehicleInfoScreen({super.key, this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: KomiutAppBar(
        title: 'Vehicle Information',
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
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.directions_car_rounded, color: theme.colorScheme.primary, size: 64),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('BASIC DETAILS', theme),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildDetailRow('Registration', vehicle?.registrationNumber.value ?? 'KBA 123X', theme),
              _buildDetailRow('Make/Model', '${vehicle?.model ?? "Toyota Hiace"} (${vehicle?.year ?? 2020})', theme),
              _buildDetailRow('Color', vehicle?.color ?? 'White', theme),
              _buildDetailRow('Capacity', '${vehicle?.capacity ?? 14} Seats', theme),
            ], theme),
            const SizedBox(height: 32),
            _buildSectionTitle('COMPLIANCE', theme),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildDetailRow('Insurance Expiry', 'Feb 12, 2025', theme, isGreen: true),
              _buildDetailRow('Inspection Expiry', 'Dec 20, 2024', theme, isGreen: true),
              _buildDetailRow('Sacco', 'Downtown Express', theme),
            ], theme),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Vehicle ID: ${vehicle?.id ?? "VH-99238"}',
                style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: AppTextStyles.label.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.5),
    );
  }

  Widget _buildInfoCard(List<Widget> children, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
              color: isGreen ? AppColors.success : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

