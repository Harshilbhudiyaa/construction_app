import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/models/site_model.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/responsive_layout.dart';
import 'package:construction_app/shared/widgets/app_logo_badge.dart';
import 'package:intl/intl.dart';

class SiteManagementScreen extends StatefulWidget {
  const SiteManagementScreen({super.key});

  @override
  State<SiteManagementScreen> createState() => _SiteManagementScreenState();
}

class _SiteManagementScreenState extends State<SiteManagementScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _isGrid = false;

  @override
  void initState() {
    super.initState();
    _isGrid = false;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final siteRepo = context.watch<SiteRepository>();
    
    var filteredSites = siteRepo.sites;
    if (_query.isNotEmpty) {
      filteredSites = filteredSites.where((s) => s.name.toLowerCase().contains(_query)).toList();
    }

    return Scaffold(
      body: ProfessionalBackground(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SmartConstructionSliverAppBar(
              title: 'Site Registry',
              subtitle: (_query.isEmpty == true) ? 'Manage construction sites' : 'Searching: "$_query"',
              category: 'SITE MANAGEMENT',
              isFull: true,
              headerStats: [
                HeroStatPill(
                  label: 'Total Sites', 
                  value: '${siteRepo.sites.length}', 
                  icon: Icons.foundation_rounded, 
                  color: bcAmber,
                  onTap: () {}, 
                ),
                HeroStatPill(
                  label: 'With Budget', 
                  value: '${siteRepo.sites.where((s) => s.hasBudget == true).length}', 
                  icon: Icons.account_balance_wallet_rounded, 
                  color: bcSuccess,
                  onTap: () {}, 
                ),
              ],
              actions: [
                IconButton(
                  onPressed: () => _showSiteFormSheet(context, null, siteRepo),
                  icon: const Icon(Icons.add_business_rounded, color: bcAmber),
                  tooltip: 'Add Site',
                ),
              ],
            ),
          ],
          body: Builder(
            builder: (context) {
              if (siteRepo.isLoading == true) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return Column(
                children: [
                   Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                     child: Row(
                       children: [
                         Expanded(
                           child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(fontSize: 15, color: bcTextPrimary, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: 'Search sites...',
                              hintStyle: TextStyle(color: bcTextSecondary.withValues(alpha: 0.6), fontSize: 14),
                              prefixIcon: const Icon(Icons.search_rounded, color: bcTextSecondary, size: 22),
                              suffixIcon: (_query.isNotEmpty == true)
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded, color: bcTextSecondary),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _query = '');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: bcBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: bcBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: bcNavy, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onChanged: (v) => setState(() => _query = v.toLowerCase()),
                          ),
                         ),
                         const SizedBox(width: 12),
                         GestureDetector(
                           onTap: () => setState(() => _isGrid = !_isGrid),
                           child: AnimatedContainer(
                             duration: const Duration(milliseconds: 200),
                             height: 52,
                             width: 52,
                             decoration: BoxDecoration(
                               color: (_isGrid == true) ? bcNavy : Colors.white,
                               borderRadius: BorderRadius.circular(16),
                               border: Border.all(color: (_isGrid == true) ? bcNavy : bcBorder),
                               boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                             ),
                             child: Icon(
                               (_isGrid == true) ? Icons.view_headline_rounded : Icons.grid_view_rounded,
                               color: (_isGrid == true) ? Colors.white : bcNavy,
                               size: 20,
                             ),
                           ),
                         ),
                       ],
                     ),
                  ),
                  Expanded(
                    child: (filteredSites.isEmpty == true)
                        ? EmptyState(
                            icon: Icons.business_outlined,
                            title: (_query.isEmpty == true) ? 'No Sites Found' : 'No Results Found',
                            message: (_query.isEmpty == true) 
                                ? 'Add your first construction site to get started.'
                                : 'Try searching with a different term.',
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: (_isGrid == true) 
                              ? GridView.builder(
                                  padding: const EdgeInsets.only(bottom: 100),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemCount: filteredSites.length,
                                  itemBuilder: (context, i) => _SiteGridCard(
                                    site: filteredSites[i],
                                    onEdit: () => _showSiteFormSheet(context, filteredSites[i], siteRepo),
                                    onDelete: () => _confirmDelete(context, filteredSites[i], siteRepo),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 100),
                                  itemCount: filteredSites.length,
                                  itemBuilder: (context, i) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _SiteCard(
                                      site: filteredSites[i],
                                      onEdit: () => _showSiteFormSheet(context, filteredSites[i], siteRepo),
                                      onDelete: () => _confirmDelete(context, filteredSites[i], siteRepo),
                                    ),
                                  ),
                                ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SiteModel site, SiteRepository repo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Site', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900)),
        content: Text('Permanently delete "${site.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: bcDanger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await repo.deleteSite(site.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${site.name} deleted.'), backgroundColor: bcDanger),
        );
      }
    }
  }

  void _showSiteFormSheet(BuildContext context, SiteModel? site, SiteRepository repo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SiteFormSheet(site: site, repo: repo),
    );
  }
}

class _SiteGridCard extends StatelessWidget {
  final SiteModel site;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SiteGridCard({required this.site, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      useGlass: true,
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLogoBadge(size: 32, padding: 0, zoom: 1.15),
              const Spacer(),
              Text(
                site.name,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: bcNavy, letterSpacing: -0.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (site.address != null && site.address!.isNotEmpty)
                Text(
                  site.address!, 
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.w600), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                   if (site.hasBudget == true && site.budgetAmount != null)
                    Expanded(
                      child: _InfoChip(
                        Icons.account_balance_rounded, 
                        '₹${NumberFormat.compact().format(site.budgetAmount)}', 
                        bcSuccess
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0, right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SmallIconButton(icon: Icons.edit_rounded, color: Colors.blueAccent, onTap: onEdit),
                const SizedBox(width: 4),
                _SmallIconButton(icon: Icons.delete_rounded, color: bcDanger, onTap: onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallIconButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 14),
      ),
    );
  }
}

class _SiteCard extends StatelessWidget {
  final SiteModel site;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SiteCard({required this.site, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      useGlass: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const AppLogoBadge(size: 42, padding: 0, zoom: 1.15),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site.name,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: bcNavy, letterSpacing: -0.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (site.address != null && site.address!.isNotEmpty)
                      Text(site.address!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 18),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Edit Site',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded, color: bcDanger, size: 18),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Delete Site',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (site.hasBudget == true && site.budgetAmount != null)
                _InfoChip(Icons.account_balance_rounded, '₹${NumberFormat.compact().format(site.budgetAmount)}', bcSuccess),
              if (site.hasBudget != true) 
                _InfoChip(Icons.money_off_rounded, 'No Budget', Colors.grey),
              const Spacer(),
              Text(
                'Created ${DateFormat('dd MMM yyyy').format(site.createdAt)}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SiteFormSheet extends StatefulWidget {
  final SiteModel? site;
  final SiteRepository repo;
  const _SiteFormSheet({required this.site, required this.repo});

  @override
  State<_SiteFormSheet> createState() => _SiteFormSheetState();
}

class _SiteFormSheetState extends State<_SiteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _budgetCtrl;
  late bool _hasBudget;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.site?.name ?? '');
    _addressCtrl = TextEditingController(text: widget.site?.address ?? '');
    _budgetCtrl = TextEditingController(text: widget.site?.budgetAmount?.toStringAsFixed(0) ?? '');
    _hasBudget = widget.site?.hasBudget ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final site = SiteModel(
        id: widget.site?.id ?? 'S-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        hasBudget: _hasBudget,
        budgetAmount: _hasBudget && _budgetCtrl.text.isNotEmpty
            ? double.tryParse(_budgetCtrl.text)
            : null,
        createdAt: widget.site?.createdAt ?? DateTime.now(),
      );
      if (widget.site == null) {
        await widget.repo.addSite(site);
      } else {
        await widget.repo.updateSite(site);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.site == null ? '${site.name} added!' : '${site.name} updated!'),
            backgroundColor: bcSuccess,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: bcDanger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(
                widget.site == null ? 'Add New Site' : 'Edit Site',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: bcNavy),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Site Name *',
                  prefixIcon: const Icon(Icons.business_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: InputDecoration(
                  labelText: 'Address (Optional)',
                  prefixIcon: const Icon(Icons.location_on_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _hasBudget,
                onChanged: (v) => setState(() => _hasBudget = v),
                title: const Text('Has Budget Allocation', style: TextStyle(fontWeight: FontWeight.w600, color: bcNavy)),
                activeThumbColor: bcAmber,
                contentPadding: EdgeInsets.zero,
              ),
              if (_hasBudget == true) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Budget Amount (₹)',
                    prefixIcon: const Icon(Icons.currency_rupee_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (_hasBudget == true) && (v == null || v.isEmpty) ? 'Budget amount is required' : null,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bcAmber,
                    foregroundColor: bcNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: bcNavy, strokeWidth: 2))
                      : Text(
                          widget.site == null ? 'SAVE SITE' : 'UPDATE SITE',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
