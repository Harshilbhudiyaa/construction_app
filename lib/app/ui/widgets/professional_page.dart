import 'package:flutter/material.dart';
import '../../theme/professional_theme.dart';
import 'responsive_sidebar.dart';

/// A standardized screen wrapper that applies the professional background,
/// a themed AppBar, and automatic support for the responsive sidebar/drawer.
class ProfessionalPage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final EdgeInsets? padding;

  const ProfessionalPage({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.bottom,
    this.floatingActionButton,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we're inside a ResponsiveSidebar (for the menu icon)
    final sidebarProvider = SidebarProvider.of(context);
    final isMobile = sidebarProvider?.isMobile ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: isMobile
            ? IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => SidebarProvider.openDrawer(context),
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: actions,
        bottom: bottom,
      ),
      floatingActionButton: floatingActionButton,
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
