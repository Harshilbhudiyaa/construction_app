import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/ledger_repository.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/features/ledger/screens/party_ledger_screen.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';

class LedgerOverviewScreen extends StatefulWidget {
  const LedgerOverviewScreen({super.key});

  @override
  State<LedgerOverviewScreen> createState() => _LedgerOverviewScreenState();
}

class _LedgerOverviewScreenState extends State<LedgerOverviewScreen> {
  final _search = TextEditingController();
  String _query = '';
  PartyCategory? _filterCategory;
  String? _balanceFilter; // 'receivable', 'payable' or null

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ledgerRepo = context.watch<LedgerRepository>();
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return ProfessionalPage(
      title: 'Party Ledger',
      subtitle: _balanceFilter == null 
          ? 'Financial accounts and balances'
          : 'Showing ${_balanceFilter}s only',
      category: 'ACCOUNTS & LEDGER',
      headerStats: [
        HeroStatPill(
          label: 'Receivable',
          value: fmt.format(ledgerRepo.getTotalReceivable()),
          icon: Icons.trending_up_rounded,
          color: bcSuccess,
          showBorder: _balanceFilter == 'receivable',
          onTap: () => setState(() => _balanceFilter = _balanceFilter == 'receivable' ? null : 'receivable'),
        ),
        HeroStatPill(
          label: 'Payable',
          value: fmt.format(ledgerRepo.getTotalPayable()),
          icon: Icons.trending_down_rounded,
          color: bcDanger,
          showBorder: _balanceFilter == 'payable',
          onTap: () => setState(() => _balanceFilter = _balanceFilter == 'payable' ? null : 'payable'),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Search parties...',
                    hintStyle: TextStyle(color: bcTextSecondary.withValues(alpha: 0.6)),
                    prefixIcon: const Icon(Icons.search_rounded, color: bcTextSecondary),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: bcTextSecondary),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: bcBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: bcBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: bcNavy, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                ),
                const SizedBox(height: 10),
                // Category filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _filterCategory == null,
                        onTap: () => setState(() => _filterCategory = null),
                      ),
                      ...PartyCategory.values.map((c) => _FilterChip(
                            label: c.displayName,
                            selected: _filterCategory == c,
                            onTap: () => setState(
                                () => _filterCategory = _filterCategory == c ? null : c),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      children: [
        Consumer<PartyRepository>(
          builder: (context, partyRepo, child) {
            var parties = partyRepo.parties;

            // Apply category filter
            if (_filterCategory != null) {
              parties = parties.where((p) => p.category == _filterCategory).toList();
            }
            // Apply search query
            if (_query.isNotEmpty) {
              parties = parties
                  .where((p) => p.name.toLowerCase().contains(_query))
                  .toList();
            }
            // Apply balance filter
            if (_balanceFilter != null) {
              parties = parties.where((p) {
                final bal = ledgerRepo.getBalanceForParty(p.id);
                if (_balanceFilter == 'receivable') return bal > 0;
                if (_balanceFilter == 'payable') return bal < 0;
                return true;
              }).toList();
            }

            if (parties.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          size: 64, color: bcTextSecondary.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const Text(
                        'No parties found',
                        style: TextStyle(
                            color: bcTextSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Add parties in the Party Registry first.',
                        style: TextStyle(color: bcTextSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }

            final balances = ledgerRepo.getAllPartyBalances();

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                children: List.generate(parties.length, (i) {
                  final party = parties[i];
                  final balance = balances[party.id] ?? 0.0;
                  final isPositive = balance >= 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PartyLedgerCard(
                      party: party,
                      balance: balance,
                      isPositive: isPositive,
                      formattedBalance: fmt.format(balance.abs()),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PartyLedgerScreen(party: party),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }
}

// _SummaryChip removed as it is replaced by HeroStatPill

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? bcNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? bcNavy : bcBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : bcTextPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PartyLedgerCard extends StatelessWidget {
  final PartyModel party;
  final double balance;
  final bool isPositive;
  final String formattedBalance;
  final VoidCallback onTap;

  const _PartyLedgerCard({
    required this.party,
    required this.balance,
    required this.isPositive,
    required this.formattedBalance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = balance == 0
        ? bcTextSecondary
        : (isPositive ? bcSuccess : bcDanger);
    final label = balance == 0
        ? 'Settled'
        : (isPositive ? 'Will Give' : 'Will Get');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bcBorder),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bcNavy.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    party.name.isNotEmpty ? party.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: bcNavy,
                        fontWeight: FontWeight.w900,
                        fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      party.name,
                      style: const TextStyle(
                        color: bcTextPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      party.category.displayName,
                      style: const TextStyle(
                        color: bcAmber,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    if (party.contactNumber != null &&
                        party.contactNumber!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.phone_rounded, size: 11, color: bcTextSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            party.contactNumber!,
                            style: const TextStyle(color: bcTextSecondary, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedBalance,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: bcTextSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
