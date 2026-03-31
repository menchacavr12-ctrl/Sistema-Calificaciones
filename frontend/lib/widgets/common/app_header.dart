import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final bool showMenu;
  final VoidCallback? onMenuTap;

  const AppHeader({
    super.key,
    this.showBack = false,
    this.showMenu = false,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: headerGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              if (showMenu)
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
                )
              else if (showBack)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.school, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              AppConstants.appNameFull,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
