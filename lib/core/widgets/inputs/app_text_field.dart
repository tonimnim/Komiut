/// AppTextField - Text input component.
///
/// A customizable text field with label, validation,
/// and password visibility toggle support.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A versatile text input field with label and validation.
class AppTextField extends StatefulWidget {
  /// Creates an AppTextField.
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.inputFormatters,
    this.autofocus = false,
    this.errorText,
    this.helperText,
    this.textCapitalization = TextCapitalization.none,
  });

  /// Creates a password field with visibility toggle.
  const AppTextField.password({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.errorText,
  })  : keyboardType = TextInputType.visiblePassword,
        obscureText = true,
        readOnly = false,
        prefix = null,
        suffix = null,
        prefixIcon = null,
        suffixIcon = null,
        maxLines = 1,
        minLines = null,
        maxLength = null,
        onTap = null,
        inputFormatters = null,
        helperText = null,
        textCapitalization = TextCapitalization.none;

  /// Creates an email field.
  const AppTextField.email({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.errorText,
  })  : keyboardType = TextInputType.emailAddress,
        obscureText = false,
        readOnly = false,
        prefix = null,
        suffix = null,
        prefixIcon = Icons.email_outlined,
        suffixIcon = null,
        maxLines = 1,
        minLines = null,
        maxLength = null,
        onTap = null,
        inputFormatters = null,
        helperText = null,
        textCapitalization = TextCapitalization.none;

  /// Creates a phone field.
  const AppTextField.phone({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.errorText,
    this.prefix,
  })  : keyboardType = TextInputType.phone,
        obscureText = false,
        readOnly = false,
        suffix = null,
        prefixIcon = Icons.phone_outlined,
        suffixIcon = null,
        maxLines = 1,
        minLines = null,
        maxLength = null,
        onTap = null,
        inputFormatters = null,
        helperText = null,
        textCapitalization = TextCapitalization.none;

  /// Field label displayed above input.
  final String? label;

  /// Hint text displayed inside input.
  final String? hint;

  /// Text controller.
  final TextEditingController? controller;

  /// Validation function.
  final String? Function(String?)? validator;

  /// Keyboard type for input.
  final TextInputType keyboardType;

  /// Whether to obscure text (for passwords).
  final bool obscureText;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Widget to display before input.
  final Widget? prefix;

  /// Widget to display after input.
  final Widget? suffix;

  /// Icon to display before input.
  final IconData? prefixIcon;

  /// Icon to display after input.
  final IconData? suffixIcon;

  /// Maximum number of lines.
  final int maxLines;

  /// Minimum number of lines.
  final int? minLines;

  /// Maximum character length.
  final int? maxLength;

  /// Callback when text changes.
  final void Function(String)? onChanged;

  /// Callback when submitted.
  final void Function(String)? onSubmitted;

  /// Callback when tapped.
  final void Function()? onTap;

  /// Focus node for the field.
  final FocusNode? focusNode;

  /// Action button on keyboard.
  final TextInputAction? textInputAction;

  /// Input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to autofocus.
  final bool autofocus;

  /// Error text to display.
  final String? errorText;

  /// Helper text to display.
  final String? helperText;

  /// Text capitalization.
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: _obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          autofocus: widget.autofocus,
          textCapitalization: widget.textCapitalization,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            helperText: widget.helperText,
            prefix: widget.prefix,
            suffix: widget.suffix,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20)
                : null,
            suffixIcon: _buildSuffixIcon(),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    // Password visibility toggle takes precedence
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      return Icon(widget.suffixIcon, size: 20);
    }

    // Custom suffix widget
    return widget.suffix;
  }
}
