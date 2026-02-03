import 'package:flutter/material.dart';
import 'package:komiut/core/theme/app_colors.dart';
import 'package:komiut/core/theme/app_text_styles.dart';

class KomiutAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? imageUrl;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showProfileIcon;
  final VoidCallback? onProfileTap;

  const KomiutAppBar({
    super.key,
    required this.title,
    this.imageUrl,
    this.actions,
    this.leading,
    this.showProfileIcon = true,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: leading,
      title: Text(
        title,
        style: AppTextStyles.heading3,
      ),
      actions: [
        if (actions != null) ...actions!,
        if (showProfileIcon)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.grey100,
                backgroundImage:
                    imageUrl != null ? NetworkImage(imageUrl!) : null,
                child: imageUrl == null
                    ? const Icon(Icons.person,
                        size: 20, color: AppColors.grey400)
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
