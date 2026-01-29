import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/shared/widgets/komiut_app_bar.dart';
import 'package:komiut/shared/widgets/komiut_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:komiut/core/routes/route_names.dart';
import 'package:komiut/core/widgets/buttons/app_button.dart';

class PreQueueScreen extends StatelessWidget {
  const PreQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: KomiutAppBar(
        title: 'Approaching Terminal',
        showProfileIcon: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Map
          const SizedBox.expand(
            child: KomiutMap(
              initialPosition: LatLng(-1.2867, 36.8172),
              zoom: 16,
            ),
          ),
          
          // Overlay UI
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: theme.shadowColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on_rounded, color: theme.colorScheme.primary, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text('Almost There!', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(
                    'You are 200m from the Downtown Express terminal. You can join the queue once you arrive.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body2.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  AppButton.primary(
                    onPressed: () {
                      context.push(RouteNames.driverDashboard, extra: {'initialTab': 1});
                    },
                    label: 'ARRIVED AT TERMINAL',
                    size: ButtonSize.large,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

