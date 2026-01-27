import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/dashboard/engineer_shell.dart';
import 'package:construction_app/profiles/engineer_model.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/services/mock_engineer_service.dart';
import 'package:construction_app/profiles/engineer_form_screen.dart';

class SiteAccessScreen extends StatefulWidget {
  const SiteAccessScreen({super.key});

  @override
  State<SiteAccessScreen> createState() => _SiteAccessScreenState();
}

class _SiteAccessScreenState extends State<SiteAccessScreen> {
  String _searchQuery = '';
  EngineerRole? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Consumer<MockEngineerService>(
      builder: (context, service, child) {
        final allEngineers = service.engineers;
        final filteredEngineers = allEngineers.where((e) {
          final matchesSearch = e.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesFilter = _selectedFilter == null || e.role == _selectedFilter;
          return matchesSearch && matchesFilter;
        }).toList();

        final activeCount = allEngineers.where((e) => e.isActive).length;

        return ProfessionalPage(
          title: 'Access Command',
          padding: const EdgeInsets.only(top: 8),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EngineerFormScreen(),
                  ),
                );
              },
              icon: Icon(Icons.person_add_rounded, color: Theme.of(context).colorScheme.primary),
              tooltip: 'Register Personnel',
            ),
          ],
          children: [
            // 1. Dashboard Stats
            _buildAccessStats(allEngineers.length, activeCount),

            const SizedBox(height: 16),

            // 2. Control Bar (Search & Filter)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                   AppSearchField(
                    hint: 'Search by name or phone...',
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Personnel List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: filteredEngineers.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: filteredEngineers.asMap().entries.map((entry) {
                        return StaggeredAnimation(
                          index: entry.key,
                          child: _buildPersonnelCard(context, entry.value),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _buildAccessStats(int total, int active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCard(label: 'Registered', value: '$total', icon: Icons.badge_rounded, color: Colors.blueAccent),
          const SizedBox(width: 12),
          _StatCard(label: 'Active Now', value: '$active', icon: Icons.sensors_rounded, color: Colors.greenAccent),
          const SizedBox(width: 12),
          _StatCard(label: 'Pending', value: '0', icon: Icons.pending_actions_rounded, color: Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChoice(
            label: 'All',
            isSelected: _selectedFilter == null,
            onTap: () => setState(() => _selectedFilter = null),
          ),
          ...EngineerRole.values.map((role) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _FilterChoice(
              label: role.displayName,
              isSelected: _selectedFilter == role,
              onTap: () => setState(() => _selectedFilter = role),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPersonnelCard(BuildContext context, EngineerModel engineer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ProfessionalCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _Avatar(name: engineer.name, color: engineer.isActive ? Colors.blueAccent : Colors.grey),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        engineer.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        (engineer.role == EngineerRole.other && engineer.customRoleName != null)
                            ? engineer.customRoleName!
                            : engineer.role.displayName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  status: engineer.isActive ? UiStatus.ok : UiStatus.stop,
                  labelOverride: engineer.isActive ? 'ACTIVE' : 'OFFLINE',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.1), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: SITE-${engineer.id.toUpperCase()}',
                      style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      IconButton(
                        onPressed: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EngineerFormScreen(engineer: engineer),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        color: const Color(0xFF546E7A),
                        tooltip: 'Edit',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                      IconButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Personnel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900)),
                              content: Text('Are you sure you want to remove ${engineer.name}?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('CANCEL', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)))),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                  child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            Provider.of<MockEngineerService>(context, listen: false).deleteEngineer(engineer.id);
                          }
                        },
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        tooltip: 'Remove',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withOpacity(0.15),
                              Colors.blueAccent.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EngineerShell(engineerId: engineer.id),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.login_rounded, size: 16, color: Colors.blueAccent.shade200),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.person_search_rounded, size: 64, color: const Color(0xFF1A237E).withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'No personnel found',
            style: TextStyle(color: const Color(0xFF1A237E).withOpacity(0.5), fontWeight: FontWeight.bold),
          ),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: const Color(0xFF78909C).withOpacity(0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: ProfessionalCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(12),
        color: colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChoice extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChoice({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? colorScheme.primary 
            : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
              ? colorScheme.primary 
              : (isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
              ? colorScheme.onPrimary 
              : colorScheme.onSurface.withOpacity(0.7),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final Color color;

  const _Avatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
