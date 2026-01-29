import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';
import 'package:komiut/core/widgets/buttons/app_button.dart';

class PayoutMethodsScreen extends StatefulWidget {
  const PayoutMethodsScreen({super.key});

  @override
  State<PayoutMethodsScreen> createState() => _PayoutMethodsScreenState();
}

class _PayoutMethodsScreenState extends State<PayoutMethodsScreen> {
  // Mock data
  final List<PayoutMethod> _methods = [
    PayoutMethod(
      id: '1',
      type: 'M-PESA',
      identifier: '0712 *** 789',
      isDefault: true,
      lastUsed: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PayoutMethod(
      id: '2',
      type: 'EQUITY BANK',
      identifier: '**** **** **** 4521',
      isDefault: false,
      lastUsed: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Payout Methods'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _methods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildMethodCard(_methods[index], theme);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: AppButton.primary(
              onPressed: _showAddMethodDialog,
              icon: Icons.add_rounded,
              label: 'ADD NEW METHOD',
              size: ButtonSize.large,
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(PayoutMethod method, ThemeData theme) {
    final bool isMpesa = method.type == 'M-PESA';
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: method.isDefault ? theme.colorScheme.primary : theme.dividerColor,
          width: method.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            setState(() {
              for (var m in _methods) {
                m.isDefault = (m.id == method.id);
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isMpesa ? AppColors.success.withOpacity(0.1) : theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      isMpesa ? Icons.phone_android_rounded : Icons.account_balance_rounded,
                      color: isMpesa ? AppColors.success : theme.colorScheme.error,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.type,
                        style: AppTextStyles.overline.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method.identifier,
                        style: AppTextStyles.heading4.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                if (method.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Default',
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Icon(Icons.radio_button_unchecked, color: theme.dividerColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMethodDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Payout Method', style: AppTextStyles.heading3),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.phone_android_rounded, color: AppColors.success),
              title: const Text('M-Pesa'),
              subtitle: const Text('Instant payout to mobile wallet'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                // navigate to detailed add screen
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.account_balance_rounded, color: Theme.of(context).colorScheme.error),
              title: const Text('Bank Account'),
              subtitle: const Text('Payments within 2-3 days'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class PayoutMethod {
  final String id;
  final String type;
  final String identifier;
  bool isDefault;
  final DateTime lastUsed;

  PayoutMethod({
    required this.id,
    required this.type,
    required this.identifier,
    required this.isDefault,
    required this.lastUsed,
  });
}
