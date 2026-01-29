import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut/di/injection_container.dart';
import 'package:komiut/driver/settings/domain/repositories/settings_repository.dart';
import 'package:komiut/core/widgets/buttons/app_button.dart';

class EditProfileScreen extends StatefulWidget {
  final DriverProfile? profile;
  final Vehicle? vehicle;
  const EditProfileScreen({super.key, this.profile, this.vehicle});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: (widget.profile?.name != null && widget.profile!.name.isNotEmpty) ? widget.profile!.name : 'Musa Mwange');
    _emailController = TextEditingController(text: (widget.profile?.email != null && widget.profile!.email.isNotEmpty) ? widget.profile!.email : 'musa@komiut.com');
    _phoneController = TextEditingController(text: (widget.profile?.phone != null && widget.profile!.phone.isNotEmpty) ? widget.profile!.phone : '0114945842');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final settingsRepository = getIt<SettingsRepository>();
      
      // 1. Upload photo if changed
      if (_image != null) {
        final result = await settingsRepository.uploadProfilePicture(_image!.path);
        result.fold(
          (failure) => _showError(failure.message),
          (profile) {
            // Success
          },
        );
      } else if (widget.profile?.imageUrl != null && _image == null && _photoRemoved) {
        // Photo was removed
        await settingsRepository.removeProfilePicture();
      }

      // 2. Update other profile details
      final updateResult = await settingsRepository.updateProfile({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (!mounted) return;

      updateResult.fold(
        (failure) => _showError(failure.message),
        (profile) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.success),
          );
          context.pop(true);
        },
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  bool _photoRemoved = false;

  void _showImageSourceDialog() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Change Profile Photo', style: AppTextStyles.heading3),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_image != null || widget.profile?.imageUrl != null)
                  _buildSourceOption(
                    icon: Icons.delete_outline_rounded,
                    label: 'Remove',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _image = null;
                        _photoRemoved = true;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({required IconData icon, required String label, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: label == 'Remove' ? theme.colorScheme.error.withOpacity(0.1) : theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: label == 'Remove' ? theme.colorScheme.error : theme.colorScheme.primary, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600, color: label == 'Remove' ? theme.colorScheme.error : null)),
        ],
      ),
    );
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.heading4.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              backgroundImage: _image != null 
                                  ? FileImage(_image!) 
                                  : (widget.profile?.imageUrl != null && !_photoRemoved ? NetworkImage(widget.profile!.imageUrl!) as ImageProvider : null),
                              child: (_image == null && (widget.profile?.imageUrl == null || _photoRemoved))
                                  ? const Icon(Icons.person, size: 40) 
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildInputField(
                    label: 'FULL NAME',
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                    validator: (val) => val!.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildInputField(
                    label: 'EMAIL ADDRESS',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val!.isEmpty ? 'Email is required' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildInputField(
                    label: 'PHONE NUMBER',
                    controller: _phoneController,
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    validator: (val) => val!.isEmpty ? 'Phone number is required' : null,
                  ),
                  const SizedBox(height: 48),
                  AppButton.primary(
                    onPressed: _isLoading ? null : _handleSave,
                    isLoading: _isLoading,
                    label: 'SAVE CHANGES',
                    size: ButtonSize.large,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: theme.shadowColor.withOpacity(0.12),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 22),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error.withOpacity(0.2)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
