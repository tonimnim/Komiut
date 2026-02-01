import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komiut/core/theme/theme_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:komiut/core/routes/route_names.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut/di/injection_container.dart';
import 'package:komiut/shared/auth/domain/repositories/auth_repository.dart';
import 'package:komiut/driver/dashboard/presentation/widgets/dashboard_widgets.dart';
import 'package:komiut/core/widgets/buttons/app_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final DriverProfile? profile;
  final Vehicle? vehicle;
  final VoidCallback? onRefresh;
  final Function(bool)? onStatusChanged;

  const ProfileScreen({
    super.key,
    this.profile,
    this.vehicle,
    this.onRefresh,
    this.onStatusChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  DriverProfile? get profile => widget.profile;
  Vehicle? get vehicle => widget.vehicle;
  VoidCallback? get onRefresh => widget.onRefresh;
  Function(bool)? get onStatusChanged => widget.onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroHeader(theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile section moved to header
                  
                  _buildSectionTitle('ACCOUNT', theme),
                  const SizedBox(height: 12),
                  _buildActionCard(theme, [
                    _buildActionRow(Icons.edit_outlined, 'Edit Profile', () async {
                      final result = await context.push(RouteNames.editProfile, extra: {'profile': profile, 'vehicle': vehicle});
                      if (result == true && onRefresh != null) {
                        onRefresh!();
                      }
                    }, theme: theme),
                    _buildActionRow(Icons.description_outlined, 'Driver Documents', () {
                      context.push(RouteNames.driverDocuments);
                    }, theme: theme),
                    _buildActionRow(Icons.account_balance_wallet_outlined, 'Payout Methods', () {
                      context.push(RouteNames.payoutMethods);
                    }, theme: theme),
                  ]),
                  const SizedBox(height: 24),

                  _buildSectionTitle('VEHICLE', theme),
                  const SizedBox(height: 12),
                  _buildActionCard(theme, [
                    _buildActionRow(Icons.directions_car_outlined, 'Vehicle Info', () => context.push(RouteNames.vehicleInfo, extra: vehicle), 
                      subtitle: '${vehicle?.model ?? "Toyota Hiace"} • ${vehicle?.registrationNumber.value ?? "KBA 123X"}', theme: theme),
                  ]),
                  const SizedBox(height: 24),

                  _buildSectionTitle('PREFERENCES', theme),
                  const SizedBox(height: 12),
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) {
                      final isDark = state.themeMode == ThemeMode.dark;
                      return _buildActionCard(theme, [
                        _buildToggleRow(
                          Icons.dark_mode_outlined, 
                          'Dark Mode', 
                          isDark ? 'On' : 'Off',
                          isDark, 
                          (val) => context.read<ThemeBloc>().add(ToggleTheme(val)),
                          theme,
                        ),
                        _buildToggleRow(
                          Icons.notifications_none_rounded, 
                          'Notifications', 
                          _notificationsEnabled ? 'Enabled' : 'Disabled',
                          _notificationsEnabled, 
                          (val) => _toggleNotifications(val),
                          theme,
                        ),
                         _buildToggleRow(
                          Icons.online_prediction_rounded, 
                          'Active Status', 
                          profile?.status == 1 ? 'On Duty' : 'Off Duty',
                          profile?.status == 1, 
                          (val) {
                            if (onStatusChanged != null) {
                              onStatusChanged!(val);
                            }
                          },
                          theme,
                        ),
                      ]);
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('APP', theme),
                  const SizedBox(height: 12),
                  _buildActionCard(theme, [
                    _buildActionRow(Icons.info_outline_rounded, 'App Info', () => context.push(RouteNames.appInfo), theme: theme),
                    _buildActionRow(Icons.privacy_tip_outlined, 'Privacy Policy', () => context.push(RouteNames.privacyTerms, extra: true), theme: theme),
                    _buildActionRow(Icons.description_outlined, 'Terms of Service', () => context.push(RouteNames.privacyTerms, extra: false), theme: theme),
                    _buildActionRow(Icons.help_outline_rounded, 'Help & Support', () {}, theme: theme),
                  ]),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context, theme),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'App Version 1.0.0\nPowered by Komiut Platform',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: profile?.imageUrl != null ? NetworkImage(profile!.imageUrl!) : null,
            child: profile?.imageUrl == null ? Icon(Icons.person, color: theme.colorScheme.primary) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (profile?.name != null && profile!.name.isNotEmpty) ? profile!.name : 'Musa Mwange', 
                  style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)
                ),
                Text(
                  (profile?.phone != null && profile!.phone.isNotEmpty) ? profile!.phone : '0114945842', 
                  style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant)
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(ThemeData theme) {
    final years = (profile?.createdAt != null) ? (DateTime.now().difference(profile!.createdAt).inDays / 365).floor() : 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),

      decoration: const BoxDecoration(
        gradient: AppColors.walletCardGradient,
      ),
      child: Column(
        children: [
          Row(
            children: [

              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: profile?.imageUrl != null ? NetworkImage(profile!.imageUrl!) : null,
                  child: profile?.imageUrl == null ? const Icon(Icons.person, color: Colors.white, size: 32) : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (profile?.name != null && profile!.name.isNotEmpty) ? profile!.name : 'Driver', 
                      style: AppTextStyles.heading3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (profile?.phone != null && profile!.phone.isNotEmpty) ? profile!.phone : '', 
                      style: AppTextStyles.body2.copyWith(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
                // Pro driver badge removed
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStat(Icons.star_rounded, profile?.rating?.toStringAsFixed(1) ?? '0.0', 'Rating'),
                _buildHeaderDivider(),
                _buildHeaderStat(Icons.directions_car_filled_rounded, '${profile?.totalTrips ?? 0}', 'Trips'),
                _buildHeaderDivider(),
                _buildHeaderStat(Icons.workspace_premium_rounded, '$years ${years == 1 ? 'Year' : 'Years'}', 'Experience'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(value, style: AppTextStyles.heading4.copyWith(color: Colors.white, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.7), fontSize: 11)),
      ],
    );
  }

  Widget _buildHeaderDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildVehicleDetailCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _buildDetailRow('Registration', vehicle?.registrationNumber.value ?? 'KBA 123X', theme: theme),
          _buildDetailRow('Make/Model', '${vehicle?.model ?? "Toyota Hiace"} (${vehicle?.year ?? 2020})', theme: theme),
          _buildDetailRow('Capacity', '${vehicle?.capacity ?? 14} Seats', theme: theme),
          _buildDetailRow('Color', vehicle?.color ?? 'White', theme: theme),
          const Divider(height: 32),
          _buildDetailRow('Insurance Expiry', 'Feb 12, 2025', isGreen: true, theme: theme),
          _buildDetailRow('Inspection Expiry', 'Dec 20, 2024', isGreen: true, theme: theme),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isGreen = false, required ThemeData theme}) {
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

  Widget _buildActionCard(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionRow(IconData icon, String title, VoidCallback onTap, {String? subtitle, required ThemeData theme}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      subtitle: subtitle != null ? Text(subtitle, style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant)) : null,
      trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildToggleRow(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged, ThemeData theme) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      subtitle: Text(subtitle, style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      trailing: Switch.adaptive(
        value: value, 
        onChanged: onChanged, 
        activeColor: AppColors.success,
        activeTrackColor: AppColors.success.withOpacity(0.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  String _getInsuranceStatus() {
    if (vehicle?.insuranceExpiry == null) return 'Expires in -- days';
    final days = vehicle!.insuranceExpiry!.difference(DateTime.now()).inDays;
    return 'Expires in $days days';
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: AppButton.outlined(
        label: 'LOGOUT',
        onPressed: () async {
          await getIt<AuthRepository>().logout();
          if (context.mounted) {
            context.go(RouteNames.login);
          }
        },
        icon: Icons.logout_rounded,
        borderColor: AppColors.redAccent,
        foregroundColor: AppColors.redAccent,
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String message, IconData icon) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Icon(icon, color: theme.colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(title, style: AppTextStyles.heading3.copyWith(color: theme.colorScheme.onSurface)),
                  ],
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style: AppTextStyles.body1.copyWith(color: theme.colorScheme.onSurface, height: 1.6),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: AppButton.primary(
                    label: 'GOT IT',
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVehicleInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Vehicle Details', style: AppTextStyles.heading3.copyWith(color: theme.colorScheme.onSurface)),
                const SizedBox(height: 24),
                _buildVehicleDetailCard(theme),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: AppButton.primary(
                    label: 'CLOSE',
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
