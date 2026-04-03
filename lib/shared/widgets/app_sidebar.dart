import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/design_system.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<SidebarDestination> destinations;
  final String? userName;
  final String? userRole;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.userName,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Construction Theme: Always Light/Professional

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: DesignSystem.surfaceWhite,
          border: const Border(
            right: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Profile Photo
              Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  children: [
                    // Profile Photo / Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: DesignSystem.charcoalBlack,
                        shape: BoxShape.circle,
                        border: Border.all(color: DesignSystem.constructionYellow, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: DesignSystem.constructionYellow,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // User Name
                    Text(
                      userName ?? 'Contractor Admin',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // User Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: DesignSystem.constructionYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: DesignSystem.constructionYellow.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        (userRole ?? 'ADMINISTRATOR').toUpperCase(),
                        style: const TextStyle(
                          color: DesignSystem.charcoalBlack,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 1,
                color: const Color(0xFFE0E0E0),
              ),

              const SizedBox(height: 8),

              // Navigation List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final destination = destinations[index];
                    return _buildNavItem(context, destination);
                  },
                ),
              ),

              // Branding Footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Text(
                      'CONSTRUCTION SUITE',
                      style: TextStyle(
                        color: DesignSystem.steelGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v2.0.0 Premium',
                      style: TextStyle(
                        color: DesignSystem.steelGrey.withValues(alpha: 0.7),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, SidebarDestination destination) {
    if (destination.children != null && destination.children!.isNotEmpty) {
      return _buildExpandableNavItem(context, destination);
    }

    final isSelected = selectedIndex == destination.index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
             if (destination.index != null) {
                onDestinationSelected(destination.index!);
             }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? DesignSystem.constructionYellow : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  destination.icon,
                  color: isSelected ? DesignSystem.charcoalBlack : DesignSystem.steelGrey,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    destination.label,
                    style: TextStyle(
                      color: isSelected ? DesignSystem.charcoalBlack : DesignSystem.textPrimary,
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (destination.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DesignSystem.warning,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      destination.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableNavItem(BuildContext context, SidebarDestination destination) {
    bool isAnyChildSelected = false;
    for (var child in destination.children!) {
      if (child.index == selectedIndex) {
        isAnyChildSelected = true;
        break;
      }
    }
    
    final isParentSelected = destination.index == selectedIndex;
    final isActive = isAnyChildSelected || isParentSelected;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
             color: isActive ? DesignSystem.concreteGrey : Colors.transparent,
             borderRadius: BorderRadius.circular(8), 
        ),
        child: ExpansionTile(
          initiallyExpanded: isActive,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(
            destination.icon,
            color: isActive ? DesignSystem.charcoalBlack : DesignSystem.steelGrey,
            size: 20,
          ),
          title: Text(
            destination.label,
            style: TextStyle(
              color: isActive ? DesignSystem.charcoalBlack : DesignSystem.textPrimary,
              fontSize: 15,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
          iconColor: DesignSystem.steelGrey,
          collapsedIconColor: DesignSystem.steelGrey,
          children: destination.children!.map((child) {
             final isChildSelected = child.index == selectedIndex;
             
             return Container(
                 margin: const EdgeInsets.only(left: 32, right: 16, bottom: 2),
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(6),
                   color: isChildSelected ? DesignSystem.constructionYellow.withValues(alpha: 0.2) : null,
                   border: isChildSelected 
                     ? Border.all(color: DesignSystem.constructionYellow.withValues(alpha: 0.5)) 
                     : null,
                 ),
                 child: ListTile(
                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                   dense: true,
                   visualDensity: VisualDensity.compact,
                   leading: Icon(
                     child.icon, 
                     size: 18, 
                     color: isChildSelected ? DesignSystem.charcoalBlack : DesignSystem.steelGrey
                   ),
                   title: Text(
                     child.label,
                     style: TextStyle(
                        fontSize: 13,
                        fontWeight: isChildSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isChildSelected ? DesignSystem.charcoalBlack : DesignSystem.textSecondary
                     ),
                   ),
                   onTap: () {
                     if (child.index != null) {
                        onDestinationSelected(child.index!);
                     }
                   },
                 ),
             );
          }).toList(),
        ),
      ),
    );
  }
}

class SidebarDestination {
  final IconData icon;
  final String label;
  final String? badge;
  final int? index;
  final List<SidebarDestination>? children;

  const SidebarDestination({
    required this.icon,
    required this.label,
    this.badge,
    this.index,
    this.children,
  });
}
