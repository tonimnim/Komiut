import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komiut_app/core/theme/theme_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart';

class ProfileScreen extends StatelessWidget {
  final DriverProfile? profile;
  final Vehicle? vehicle;

  const ProfileScreen({
    super.key,
    this.profile,
    this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('PROFILE'),
                  const SizedBox(height: 12),
                  _buildActionCard([
                    _buildProfileRow(),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('ACCOUNT'),
                  const SizedBox(height: 12),
                  _buildActionCard([
                    _buildActionRow(Icons.edit_outlined, 'Edit Profile', () => context.push(RouteNames.editProfile, extra: {'profile': profile, 'vehicle': vehicle})),
                    _buildActionRow(Icons.lock_outline_rounded, 'Change Password', () {}),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('VEHICLE'),
                  const SizedBox(height: 12),
                  _buildActionCard([
                    _buildActionRow(Icons.directions_car_outlined, 'Vehicle Info', () {}),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('PREFERENCES'),
                  const SizedBox(height: 12),
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) {
                      final isDark = state.themeMode == ThemeMode.dark;
                      return _buildActionCard([
                        _buildToggleRow(
                          Icons.dark_mode_outlined, 
                          'Dark Mode', 
                          isDark, 
                          (val) => context.read<ThemeBloc>().add(ToggleTheme(val)),
                        ),
                        _buildToggleRow(Icons.notifications_none_rounded, 'Notifications', true, (val) {}),
                      ]);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('APP'),
                  const SizedBox(height: 12),
                  _buildActionCard([
                    _buildActionRow(Icons.info_outline_rounded, 'App Info', () {}),
                    _buildActionRow(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
                    _buildActionRow(Icons.description_outlined, 'Terms of Service', () {}),
                    _buildActionRow(Icons.help_outline_rounded, 'Help & Support', () {}),
                  ]),
                  const SizedBox(height: 32),
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: profile?.imageUrl != null ? NetworkImage(profile!.imageUrl!) : null,
            child: profile?.imageUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile?.name ?? 'John Driver', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                Text(profile?.phone ?? '+254 712 345 678', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        gradient: AppColors.premiumBlueGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            backgroundImage: profile?.imageUrl != null ? NetworkImage(profile!.imageUrl!) : null,
            child: profile?.imageUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
          ),
          const SizedBox(height: 16),
          Text(profile?.name ?? 'John Driver', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text('${profile?.rating ?? 4.8} Rating', style: AppTextStyles.body2.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Text('|', style: TextStyle(color: Colors.white.withOpacity(0.3))),
              const SizedBox(width: 16),
              Text('${profile?.totalTrips ?? 156} Trips', style: AppTextStyles.body2.copyWith(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(color: AppColors.textMuted, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildVehicleDetailCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _buildDetailRow('Registration', vehicle?.registrationNumber.value ?? 'KBA 123X'),
          _buildDetailRow('Make/Model', '${vehicle?.model ?? "Toyota Hiace"} (${vehicle?.year ?? 2020})'),
          _buildDetailRow('Capacity', '${vehicle?.capacity ?? 14} Seats'),
          _buildDetailRow('Color', vehicle?.color ?? 'White'),
          const Divider(height: 32),
          _buildDetailRow('Insurance Expiry', 'Feb 12, 2025', isGreen: true),
          _buildDetailRow('Inspection Expiry', 'Dec 20, 2024', isGreen: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
              color: isGreen ? AppColors.primaryGreen : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionRow(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primaryBlue, size: 22),
      title: Text(title, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey300, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      dense: true,
    );
  }

  Widget _buildToggleRow(IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue, size: 22),
      title: Text(title, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primaryBlue),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      dense: true,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('LOGOUT'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
