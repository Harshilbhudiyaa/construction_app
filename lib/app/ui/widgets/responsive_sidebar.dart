import 'package:flutter/material.dart';
import 'app_sidebar.dart';

/// Responsive wrapper for sidebar navigation
/// Shows as drawer on mobile, permanent sidebar on larger screens
class ResponsiveSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<SidebarDestination> destinations;
  final String? userName;
  final String? userRole;
  final Widget child;

  const ResponsiveSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.userName,
    this.userRole,
    required this.child,
  });

  static const double mobileBreakpoint = 800;

  @override
  State<ResponsiveSidebar> createState() => _ResponsiveSidebarState();
}

class _ResponsiveSidebarState extends State<ResponsiveSidebar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < ResponsiveSidebar.mobileBreakpoint;

        return SidebarProvider(
          isMobile: isMobile,
          scaffoldKey: _scaffoldKey,
          child: isMobile
              ? _MobileLayout(
                  scaffoldKey: _scaffoldKey,
                  selectedIndex: widget.selectedIndex,
                  onDestinationSelected: widget.onDestinationSelected,
                  destinations: widget.destinations,
                  userName: widget.userName,
                  userRole: widget.userRole,
                  child: widget.child,
                )
              : Row(
                  children: [
                    AppSidebar(
                      selectedIndex: widget.selectedIndex,
                      onDestinationSelected: widget.onDestinationSelected,
                      destinations: widget.destinations,
                      userName: widget.userName,
                      userRole: widget.userRole,
                    ),
                    Expanded(child: widget.child),
                  ],
                ),
        );
      },
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<SidebarDestination> destinations;
  final String? userName;
  final String? userRole;
  final Widget child;

  const _MobileLayout({
    required this.scaffoldKey,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.userName,
    this.userRole,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        child: AppSidebar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            onDestinationSelected(index);
            Navigator.of(context).pop(); // Close drawer after selection
          },
          destinations: destinations,
          userName: userName,
          userRole: userRole,
        ),
      ),
      body: child,
    );
  }
}

/// InheritedWidget to provide scaffold key to child widgets
class SidebarProvider extends InheritedWidget {
  final bool isMobile;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const SidebarProvider({
    super.key,
    required this.isMobile,
    this.scaffoldKey,
    required super.child,
  });

  static SidebarProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SidebarProvider>();
  }

  /// Opens the drawer if on mobile
  static void openDrawer(BuildContext context) {
    final provider = of(context);
    if (provider?.isMobile == true && provider?.scaffoldKey?.currentState != null) {
      provider!.scaffoldKey!.currentState!.openDrawer();
    }
  }

  @override
  bool updateShouldNotify(SidebarProvider oldWidget) {
    return isMobile != oldWidget.isMobile;
  }
}
