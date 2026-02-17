import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/theme/design_system.dart';
import 'package:construction_app/services/theme_service.dart';
import 'responsive_sidebar.dart';
import 'package:provider/provider.dart';

/// A standardized screen wrapper matching login page aesthetic
class ProfessionalPage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final EdgeInsets? padding;
  final Widget? bottomNavigationBar;
  final String? subtitle;

  const ProfessionalPage({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.bottom,
    this.floatingActionButton,
    this.padding,
    this.bottomNavigationBar,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we're inside a ResponsiveSidebar
    final sidebarProvider = SidebarProvider.of(context);
    final isMobile = sidebarProvider?.isMobile ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: isMobile
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => SidebarProvider.openDrawer(context),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ),
          ],
        ),
        actions: [
          if (actions != null) ...actions!,
          const ThemeToggle(),
        ],
        bottom: bottom,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: ProfessionalBackground(
        child: SafeArea(
          child: ListView(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 0),
            children: children,
          ),
        ),
      ),
    );
  }
}

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final isDark = themeService.isDarkMode;
        return IconButton(
          onPressed: () => themeService.toggleTheme(),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              key: ValueKey(isDark),
              color: isDark ? DesignSystem.warning : DesignSystem.deepNavy,
            ),
          ),
          tooltip: 'Switch Theme',
        );
      },
    );
  }
}