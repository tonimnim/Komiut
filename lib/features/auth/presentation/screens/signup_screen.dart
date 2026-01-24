/// Sign Up Screen.
///
/// Registration for passengers only.
/// Drivers are added manually by Sacco admins from the backend.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_controller.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    await ref.read(authControllerProvider.notifier).register(
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes
    ref.listen<AsyncValue<AuthState>>(authControllerProvider, (previous, next) {
      next.whenData((authState) {
        if (!mounted) return;

        if (authState is AuthAuthenticated) {
          // Registration successful - auto-logged in, go to passenger home
          context.go(authState.role.homeRoute);
        } else if (authState is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    });

    final isLoading = ref.watch(isAuthLoadingProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, AppColors.primaryGreen],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        const Text(
                          'Sign up as a passenger to start booking',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Full Name
                        CustomTextField(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          controller: _fullNameController,
                          prefixIcon: Icons.person_outline,
                          validator: Validators.validateFullName,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        CustomTextField(
                          label: 'Email Address',
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.validateEmail,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        CustomTextField(
                          label: 'Phone Number',
                          hint: '+254 7XX XXX XXX',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: Validators.validatePhone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        CustomTextField(
                          label: 'Password',
                          hint: 'Create a password',
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          validator: Validators.validatePassword,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        CustomTextField(
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          controller: _confirmPasswordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          validator: _validateConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSignUp(),
                        ),
                        const SizedBox(height: 16),

                        // Terms checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              onChanged: (value) {
                                setState(() => _acceptedTerms = value ?? false);
                              },
                              fillColor: WidgetStateProperty.resolveWith(
                                (states) => states.contains(WidgetState.selected)
                                    ? Colors.white
                                    : Colors.transparent,
                              ),
                              checkColor: AppColors.primaryBlue,
                              side: const BorderSide(color: Colors.white70),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _acceptedTerms = !_acceptedTerms);
                                },
                                child: const Text(
                                  'I agree to the Terms & Conditions and Privacy Policy',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Sign Up button
                        CustomButton(
                          text: 'Create Account',
                          onPressed: (isLoading || _isSubmitting) ? null : _handleSignUp,
                          isLoading: isLoading || _isSubmitting,
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryBlue,
                        ),
                        const SizedBox(height: 24),

                        // Login prompt
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: () => context.pop(),
                              style: TextButton.styleFrom(foregroundColor: Colors.white),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
