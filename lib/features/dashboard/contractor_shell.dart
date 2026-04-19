import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/core/utils/navigation_utils.dart';
import 'package:construction_app/shared/widgets/app_logo_badge.dart';
import 'package:construction_app/shared/events/shell_events.dart';
import 'package:construction_app/shared/widgets/responsive_layout.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';

// Main tabs
import 'home_screen.dart';
import 'package:construction_app/features/materials/material_catalog_screen.dart';
import 'package:construction_app/features/workers/worker_list_screen.dart';
import 'package:construction_app/features/contractors/contractor_list_screen.dart';

// More-drawer destinations
import 'package:construction_app/core/routing/app_router.dart';

class ContractorShell extends StatefulWidget {
  const ContractorShell({super.key});

  @override
  State<ContractorShell> createState() => _ContractorShellState();
}

class _ContractorShellState extends State<ContractorShell>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;

  late AnimationController _indicatorAnim;

  void _goTo(int i) {
    if (_index == i) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
    _indicatorAnim.forward(from: 0);
  }

  void _showMoreSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MoreBottomSheet(onNavigate: (route, [args]) {
        Navigator.pop(context);
        Navigator.pushNamed(context, route, arguments: args);
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _indicatorAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _indicatorAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = !ResponsiveLayout.isMobile(context);

    // Core navigation tabs
    final List<_NavItem> navItems = [
      const _NavItem(icon: Icons.home_outlined,        activeIcon: Icons.home_rounded,              label: 'Home'),
      const _NavItem(icon: Icons.layers_outlined,       activeIcon: Icons.layers_rounded,            label: 'Materials'),
      const _NavItem(icon: Icons.engineering_outlined,  activeIcon: Icons.engineering_rounded,       label: 'Workers'),
      const _NavItem(icon: Icons.handyman_outlined,     activeIcon: Icons.handyman_rounded,          label: 'Contractors'),
      const _NavItem(icon: Icons.grid_view_outlined,    activeIcon: Icons.grid_view_rounded,         label: 'More'),
    ];

    final List<Widget> pages = [
      HomeScreen(onNavigateTo: _goTo),
      const MaterialCatalogScreen(),
      const WorkerListScreen(),
      const ContractorListScreen(),
      // "More" tab shows home — actual navigation happens via bottom sheet
      HomeScreen(onNavigateTo: _goTo),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (_index != 0) {
          setState(() => _index = 0);
        } else {
          await NavigationUtils.showLogoutDialog(context);
        }
      },
      child: NotificationListener<OpenShellDrawerNotification>(
        onNotification: (_) {
          _scaffoldKey.currentState?.openDrawer();
          return true;
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: bcSurface,
          drawer: isWide
              ? null
              : _DrawerSidebar(
                  currentIndex: _index,
                  navItems: navItems.sublist(0, 4),
                  onGoTo: _goTo,
                  onShowMore: () {
                    _scaffoldKey.currentState?.closeDrawer();
                    Future.delayed(
                      const Duration(milliseconds: 300),
                      () => _showMoreSheet(context),
                    );
                  },
                  onClose: () => _scaffoldKey.currentState?.closeDrawer(),
                ),
          bottomNavigationBar: isWide
              ? null
              : _BottomNavBar(
                  items: navItems,
                  currentIndex: _index,
                  onTap: (i) {
                    if (i == 4) {
                      _showMoreSheet(context);
                    } else {
                      _goTo(i);
                    }
                  },
                ),
          body: isWide
              ? Row(
                  children: [
                    _PersistentSidebar(
                      currentIndex: _index,
                      navItems: navItems.sublist(0, 4),
                      onGoTo: _goTo,
                      onShowMore: () => _showMoreSheet(context),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        child: KeyedSubtree(
                          key: ValueKey(_index),
                          child: pages[_index],
                        ),
                      ),
                    ),
                  ],
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutCubic,
                  child: KeyedSubtree(
                    key: ValueKey(_index),
                    child: pages[_index],
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Nav Item Model ───────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final void Function(int) onTap;

  const _BottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: bcNavy,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < items.length; i++)
                _BottomNavItem(
                  item: items[i],
                  active: currentIndex == i && i != 4,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatefulWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _BottomNavItem({required this.item, required this.active, required this.onTap});

  @override
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.82).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: widget.active ? bcAmber.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                widget.active ? widget.item.activeIcon : widget.item.icon,
                color: widget.active ? bcAmber : Colors.white54,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.item.label,
              style: TextStyle(
                color: widget.active ? bcAmber : Colors.white54,
                fontSize: 9.5,
                fontWeight: widget.active ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: widget.active ? 18 : 0,
              height: 2.5,
              decoration: BoxDecoration(
                color: bcAmber,
                borderRadius: BorderRadius.circular(2),
                boxShadow: widget.active
                    ? [BoxShadow(color: bcAmber.withValues(alpha: 0.5), blurRadius: 6)]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── "More" Bottom Sheet ──────────────────────────────────────────────────────

class _MoreBottomSheet extends StatelessWidget {
  final void Function(String route, [dynamic args]) onNavigate;
  const _MoreBottomSheet({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreItem('Sites',       Icons.location_city_rounded,        AppRoutes.siteManagement,    bcAmber),
      _MoreItem('Suppliers',   Icons.people_alt_rounded,           AppRoutes.supplierList,      const Color(0xFF34D399)),
      _MoreItem('Stock Entry', Icons.add_box_rounded,              AppRoutes.stockHub,          const Color(0xFF60A5FA)),
      _MoreItem('Stock Out',   Icons.output_rounded,               AppRoutes.stockOut,          const Color(0xFFEF4444)),
      _MoreItem('Payments',    Icons.account_balance_wallet_rounded,AppRoutes.paymentHistory,   const Color(0xFFA78BFA)),
      _MoreItem('Inventory',   Icons.inventory_2_rounded,          AppRoutes.materialCatalog,   const Color(0xFF10B981), args: {'inStock': true}),
      _MoreItem('Reports',     Icons.analytics_rounded,            AppRoutes.reports,           const Color(0xFFFB7185)),
      _MoreItem('Calculator',  Icons.calculate_rounded,            AppRoutes.calculatorHome,    bcAmber),
      _MoreItem('Ledger',      Icons.receipt_long_rounded,         AppRoutes.partyLedger,       const Color(0xFF10B981)),
      _MoreItem('Inward Logs', Icons.local_shipping_rounded,       AppRoutes.inwardManagement,  const Color(0xFFF59E0B)),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'MORE MODULES',
                style: TextStyle(
                  color: bcNavy, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => _MoreItemTile(item: items[i], onTap: () => onNavigate(items[i].route, items[i].args)),
          ),
        ],
      ),
    );
  }
}

class _MoreItem {
  final String label;
  final IconData icon;
  final String route;
  final Color color;
  final dynamic args;
  const _MoreItem(this.label, this.icon, this.route, this.color, {this.args});
}

class _MoreItemTile extends StatelessWidget {
  final _MoreItem item;
  final VoidCallback onTap;
  const _MoreItemTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color.withValues(alpha: 0.18)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: TextStyle(
                color: bcNavy,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Drawer Sidebar (mobile) ──────────────────────────────────────────────────

class _DrawerSidebar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onGoTo;
  final VoidCallback onShowMore;
  final VoidCallback onClose;

  const _DrawerSidebar({
    required this.currentIndex,
    required this.navItems,
    required this.onGoTo,
    required this.onShowMore,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 272,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: bcNavy,
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 40, offset: Offset(4, 0))],
      ),
      child: _SidebarContent(
        currentIndex: currentIndex,
        navItems: navItems,
        onGoTo: onGoTo,
        onShowMore: onShowMore,
        showClose: true,
        onClose: onClose,
      ),
    );
  }
}

// ─── Persistent Sidebar (wide screens) ───────────────────────────────────────

class _PersistentSidebar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onGoTo;
  final VoidCallback onShowMore;

  const _PersistentSidebar({
    required this.currentIndex,
    required this.navItems,
    required this.onGoTo,
    required this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      decoration: const BoxDecoration(
        color: bcNavy,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(4, 0))],
      ),
      child: _SidebarContent(
        currentIndex: currentIndex,
        navItems: navItems,
        onGoTo: onGoTo,
        onShowMore: onShowMore,
        showClose: false,
      ),
    );
  }
}

// ─── Shared Sidebar Content ───────────────────────────────────────────────────

class _SidebarContent extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onGoTo;
  final VoidCallback onShowMore;
  final bool showClose;
  final VoidCallback? onClose;

  const _SidebarContent({
    required this.currentIndex,
    required this.navItems,
    required this.onGoTo,
    required this.onShowMore,
    required this.showClose,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: BlueprintGridPainter(opacity: 0.12)),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  children: [
                    for (int i = 0; i < navItems.length; i++)
                      _SidebarNavItem(
                        item: navItems[i],
                        active: currentIndex == i,
                        onTap: () => onGoTo(i),
                      ),
                    const SizedBox(height: 8),
                    _SidebarMoreButton(onTap: onShowMore),
                  ],
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Row(
        children: [
          const AppLogoBadge(size: 40, padding: 0, zoom: 1.15),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SmartConstruction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
                Text('Construction ERP', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (showClose)
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bcAmber.withValues(alpha: 0.15),
              border: Border.all(color: bcAmber.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Icon(Icons.person_rounded, color: bcAmber, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Builder(builder: (ctx) {
              final auth = ctx.watch<AuthRepository>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.userName ?? 'Admin',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  Text(
                    auth.userRole?.label.toUpperCase() ?? 'ADMINISTRATOR',
                    style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }),
          ),
          GestureDetector(
            onTap: () => NavigationUtils.showLogoutDialog(context),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.white38, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _SidebarNavItem({required this.item, required this.active, required this.onTap});

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 220),
        value: widget.active ? 1.0 : 0.0);
  }

  @override
  void didUpdateWidget(covariant _SidebarNavItem old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active) {
      widget.active ? _anim.forward() : _anim.reverse();
    }
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) {
            final t = _anim.value;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Color.lerp(
                  _hovered && !widget.active ? Colors.white.withValues(alpha: 0.04) : Colors.transparent,
                  bcAmber.withValues(alpha: 0.12),
                  t,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color.lerp(Colors.transparent, bcAmber.withValues(alpha: 0.25), t)!,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 3, height: widget.active ? 20 : 0,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(color: bcAmber, borderRadius: BorderRadius.circular(2)),
                  ),
                  Icon(
                    widget.active ? widget.item.activeIcon : widget.item.icon,
                    color: Color.lerp(Colors.white38, bcAmber, t),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        color: Color.lerp(Colors.white60, Colors.white, t),
                        fontWeight: widget.active ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (widget.active)
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bcAmber,
                        boxShadow: [BoxShadow(color: bcAmber.withValues(alpha: 0.5), blurRadius: 6)],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SidebarMoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SidebarMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 13),
            const Icon(Icons.grid_view_rounded, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('More Modules', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white30, size: 18),
          ],
        ),
      ),
    );
  }
}
