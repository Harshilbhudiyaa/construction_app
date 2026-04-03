import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/responsive_layout.dart';
import 'party_form_screen.dart';
import 'party_card_screen.dart';

class PartyManagementScreen extends StatefulWidget {
  const PartyManagementScreen({super.key});

  @override
  State<PartyManagementScreen> createState() => _PartyManagementScreenState();
}

class _PartyManagementScreenState extends State<PartyManagementScreen> {
  PartyCategory? _activeFilter;
  bool _showNewOnly = false;

  Future<void> _deleteParty(BuildContext context, PartyModel party) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Party', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900)),
        content: Text('Permanently delete "${party.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: bcDanger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await PartyRepository().deleteParty(party.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${party.name} deleted.'), backgroundColor: bcDanger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfessionalBackground(
        child: Consumer<PartyRepository>(
          builder: (context, partyRepo, child) {
            final allParties = partyRepo.parties;
            
            // Filter logic
            var filteredParties = allParties;
            if (_activeFilter != null) {
              filteredParties = filteredParties.where((p) => p.category == _activeFilter).toList();
            }
            if (_showNewOnly) {
              final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
              filteredParties = filteredParties.where((p) => p.createdAt.isAfter(sevenDaysAgo)).toList();
            }
            
            final newCount = allParties.where((p) => p.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length;

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SmartConstructionSliverAppBar(
                  title: 'Party Registry',
                  subtitle: _showNewOnly 
                      ? 'Showing recently added vendors'
                      : _activeFilter == null 
                          ? 'Suppliers and business partners'
                          : 'Showing ${_activeFilter!.displayName}s only',
                  category: 'PARTIES MODULE',
                  isFull: true,
                  headerStats: [
                    HeroStatPill(
                      label: 'Total Vendors', 
                      value: '${allParties.length}', 
                      color: bcNavy,
                      showBorder: _activeFilter == null && !_showNewOnly,
                      onTap: () => setState(() {
                        _activeFilter = null;
                        _showNewOnly = false;
                      }),
                    ),
                    HeroStatPill(
                      label: 'Suppliers', 
                      value: '${allParties.where((p) => p.category == PartyCategory.supplier).length}', 
                      color: bcSuccess,
                      showBorder: _activeFilter == PartyCategory.supplier && !_showNewOnly,
                      iconWidget: const Icon(Icons.verified_user_rounded, color: bcSuccess, size: 14),
                      onTap: () => setState(() {
                        _activeFilter = PartyCategory.supplier;
                        _showNewOnly = false;
                      }),
                    ),
                    HeroStatPill(
                      label: 'New', 
                      value: '$newCount', 
                      color: bcAmber,
                      showBorder: _showNewOnly,
                      iconWidget: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: bcAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: bcAmber,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      onTap: () => setState(() {
                        _showNewOnly = !_showNewOnly;
                        if (_showNewOnly) _activeFilter = null;
                      }),
                    ),
                  ],
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PartyFormScreen()),
                      ),
                      icon: const Icon(Icons.add_circle_outline_rounded, color: bcAmber),
                      tooltip: 'Add Party',
                    ),
                  ],
                ),
              ],
              body: filteredParties.isEmpty
                  ? EmptyState(
                      icon: Icons.business_rounded,
                      title: _showNewOnly 
                          ? 'No new parties found' 
                          : _activeFilter == null ? 'No parties added yet' : 'No ${_activeFilter!.displayName}s found',
                      message: 'Add suppliers or clients to start tracking transactions.',
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ResponsiveGrid(
                        mobileCrossAxisCount: 1,
                        tabletCrossAxisCount: 2,
                        desktopCrossAxisCount: 3,
                        childAspectRatio: 2.2,
                        spacing: 16,
                        runSpacing: 16,
                        children: List.generate(filteredParties.length, (i) {
                          final party = filteredParties[i];
                          return StaggeredAnimation(
                            index: i,
                            child: ProfessionalCard(
                              useGlass: true,
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PartyCardScreen(party: party)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: bcNavy.withValues(alpha: 0.05),
                                        child: Text(
                                          party.name.isNotEmpty ? party.name[0].toUpperCase() : '?',
                                          style: const TextStyle(color: bcNavy, fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              party.name,
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: bcNavy, letterSpacing: -0.2),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              party.category.displayName.toUpperCase(),
                                              style: const TextStyle(color: bcAmber, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                            ),
                                            if (party.contactNumber != null && party.contactNumber!.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(Icons.phone_rounded, size: 12, color: Color(0xFF64748B)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    party.contactNumber!,
                                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
                                            visualDensity: VisualDensity.compact,
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => PartyFormScreen(party: party)),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_rounded, color: bcDanger),
                                            visualDensity: VisualDensity.compact,
                                            onPressed: () => _deleteParty(context, party),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

