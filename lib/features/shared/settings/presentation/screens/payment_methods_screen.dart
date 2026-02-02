/// Payment methods screen.
///
/// Displays and manages the user's saved payment methods
/// including M-Pesa numbers and cards.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/saved_payment_method.dart';
import '../providers/preferences_providers.dart';
import '../widgets/saved_item_card.dart';

/// Screen for managing saved payment methods.
class PaymentMethodsScreen extends ConsumerWidget {
  /// Creates a payment methods screen.
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final methodsAsync = ref.watch(savedPaymentMethodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(savedPaymentMethodsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: methodsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(context, ref, error.toString()),
        data: (methods) => methods.isEmpty
            ? _buildEmptyState(context, isDark)
            : _buildMethodsList(context, ref, methods),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPaymentMethodSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Method'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 80,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No Payment Methods',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your M-Pesa number or card for faster payments.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Tap the + button below to add a payment method.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[600] : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load payment methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(savedPaymentMethodsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodsList(
    BuildContext context,
    WidgetRef ref,
    List<SavedPaymentMethod> methods,
  ) {
    // Separate M-Pesa and cards, with default first
    final sortedMethods = List<SavedPaymentMethod>.from(methods)
      ..sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.addedAt.compareTo(b.addedAt);
      });

    final mpesaMethods = sortedMethods.where((m) => m.isMpesa).toList();
    final cardMethods = sortedMethods.where((m) => m.isCard).toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(savedPaymentMethodsProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // M-Pesa Section
          if (mpesaMethods.isNotEmpty) ...[
            _buildSectionHeader(context, 'M-Pesa', Icons.phone_android),
            const SizedBox(height: 12),
            ...mpesaMethods.map((method) => SavedPaymentMethodCard(
                  name: method.name,
                  maskedNumber: method.maskedNumber,
                  isMpesa: true,
                  isDefault: method.isDefault,
                  onTap: () => _showMethodOptions(context, ref, method),
                  onDelete: () => ref
                      .read(savedPaymentMethodsProvider.notifier)
                      .removePaymentMethod(method.id),
                  onSetDefault: method.isDefault
                      ? null
                      : () => ref
                          .read(savedPaymentMethodsProvider.notifier)
                          .setDefault(method.id),
                )),
            const SizedBox(height: 24),
          ],

          // Cards Section
          if (cardMethods.isNotEmpty) ...[
            _buildSectionHeader(context, 'Cards', Icons.credit_card),
            const SizedBox(height: 12),
            ...cardMethods.map((method) => SavedPaymentMethodCard(
                  name: method.name,
                  maskedNumber: method.maskedNumber,
                  isMpesa: false,
                  isDefault: method.isDefault,
                  cardBrand: method.cardBrand,
                  onTap: () => _showMethodOptions(context, ref, method),
                  onDelete: () => ref
                      .read(savedPaymentMethodsProvider.notifier)
                      .removePaymentMethod(method.id),
                  onSetDefault: method.isDefault
                      ? null
                      : () => ref
                          .read(savedPaymentMethodsProvider.notifier)
                          .setDefault(method.id),
                )),
          ],

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.grey[500] : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showAddPaymentMethodSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Add Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    color: AppColors.primaryGreen,
                  ),
                ),
                title: const Text('M-Pesa'),
                subtitle: const Text('Add your Safaricom M-Pesa number'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showAddMpesaDialog(context, ref);
                },
              ),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: AppColors.primaryBlue,
                  ),
                ),
                title: const Text('Credit/Debit Card'),
                subtitle: const Text('Add Visa, Mastercard, or other cards'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showAddCardDialog(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMpesaDialog(BuildContext context, WidgetRef ref) {
    final phoneController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add M-Pesa Number'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '07XX XXX XXX',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                  if (digits.length < 9 || digits.length > 12) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname (Optional)',
                  hintText: 'e.g., Personal M-Pesa',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                ref.read(savedPaymentMethodsProvider.notifier).addMpesa(
                      phoneNumber: phoneController.text,
                      name: nameController.text.isEmpty
                          ? null
                          : nameController.text,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('M-Pesa number added'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog(BuildContext context, WidgetRef ref) {
    final lastFourController = TextEditingController();
    final nameController = TextEditingController();
    final expiryController = TextEditingController();
    String selectedBrand = 'Visa';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Card'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedBrand,
                  decoration: const InputDecoration(
                    labelText: 'Card Brand',
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(),
                  ),
                  items: ['Visa', 'Mastercard', 'Amex', 'Other']
                      .map((brand) => DropdownMenuItem(
                            value: brand,
                            child: Text(brand),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedBrand = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: lastFourController,
                  decoration: const InputDecoration(
                    labelText: 'Last 4 Digits',
                    hintText: '1234',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (value) {
                    if (value == null || value.length != 4) {
                      return 'Please enter the last 4 digits';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter valid digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: expiryController,
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expiry date';
                    }
                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                      return 'Use MM/YY format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nickname (Optional)',
                    hintText: 'e.g., Personal Card',
                    prefixIcon: Icon(Icons.label),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  ref.read(savedPaymentMethodsProvider.notifier).addCard(
                        lastFourDigits: lastFourController.text,
                        cardBrand: selectedBrand,
                        name: nameController.text.isEmpty
                            ? null
                            : nameController.text,
                        expiryDate: expiryController.text,
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Card added'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMethodOptions(
    BuildContext context,
    WidgetRef ref,
    SavedPaymentMethod method,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.maskedNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!method.isDefault)
                ListTile(
                  leading: const Icon(Icons.star_outline),
                  title: const Text('Set as Default'),
                  onTap: () {
                    ref
                        .read(savedPaymentMethodsProvider.notifier)
                        .setDefault(method.id);
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Remove Payment Method',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmRemove(context, ref, method);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    SavedPaymentMethod method,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Payment Method'),
        content: Text('Are you sure you want to remove "${method.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(savedPaymentMethodsProvider.notifier)
                  .removePaymentMethod(method.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
