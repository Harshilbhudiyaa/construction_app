import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';

import 'package:construction_app/data/repositories/labour_repository.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';

import 'package:construction_app/data/models/labour_entry_model.dart';

class ContractorDashboardScreen extends StatelessWidget {
  const ContractorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final labourRepo = context.watch<LabourRepository>();
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    
    // Filter entries for the current contractor
    final contractorName = authRepo.userName ?? '';
    final contractorEntries = labourRepo.entries.where((e) => e.partyName.toLowerCase() == contractorName.toLowerCase()).toList();
    
    final totalEarnings = contractorEntries.fold(0.0, (sum, e) => sum + e.totalContractAmount);
    final advanceTaken = contractorEntries.fold(0.0, (sum, e) => sum + e.totalAdvancePaid + (e.finalSettlementAmount ?? 0));
    final pendingBalance = contractorEntries.fold(0.0, (sum, e) => sum + e.pendingAmount);
    final activeWorkCount = contractorEntries.where((e) => e.status == LabourStatus.ongoing).length;

    return ProfessionalPage(
      title: 'Contractor Dashboard',
      subtitle: 'Welcome back, $contractorName',
      category: 'PERSONAL WORKSPACE',
      headerStats: [
        HeroStatPill(
          label: 'Active Jobs',
          value: activeWorkCount.toString(),
          color: bcAmber,
          icon: Icons.engineering_rounded,
        ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfessionalSectionHeader(
                  title: 'FINANCIAL OVERVIEW',
                  subtitle: 'Earnings and pending settlements',
                ),
                const SizedBox(height: 16),
                _buildFinancialRow(context, fmt, totalEarnings, advanceTaken, pendingBalance),
                
                const SizedBox(height: 32),
                const ProfessionalSectionHeader(
                  title: 'ASSIGNED WORK',
                  subtitle: 'Tap a contract for details',
                ),
                const SizedBox(height: 16),
                if (contractorEntries.isEmpty)
                  _buildEmptyState()
                else
                  ...contractorEntries.map((e) => _buildContractTile(context, e, fmt)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRow(BuildContext context, NumberFormat fmt, double total, double paid, double pending) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Earnings',
            value: fmt.format(total),
            color: bcInfo,
            icon: Icons.account_balance_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Paid to Date',
            value: fmt.format(paid),
            color: bcSuccess,
            icon: Icons.check_circle_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Pending Balance',
            value: fmt.format(pending),
            color: bcDanger,
            icon: Icons.hourglass_empty_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildContractTile(BuildContext context, LabourEntryModel e, NumberFormat fmt) {
    final statusColor = _getStatusColor(e.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusPill(label: e.status.displayName, color: statusColor),
                const Spacer(),
                Text(
                  fmt.format(e.totalContractAmount),
                  style: const TextStyle(fontWeight: FontWeight.w900, color: bcNavy),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              e.workType.displayName,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: bcNavy),
            ),
            Text(
              e.siteName,
              style: TextStyle(color: bcNavy.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: e.totalContractAmount > 0 ? (e.totalAdvancePaid / e.totalContractAmount) : 0,
              backgroundColor: bcNavy.withValues(alpha: 0.05),
              color: statusColor,
              minHeight: 4,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid: ${fmt.format(e.totalAdvancePaid)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: bcTextSecondary),
                ),
                Text(
                  'Pending: ${fmt.format(e.pendingAmount)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: bcDanger),
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
          Icon(Icons.assignment_ind_rounded, size: 64, color: bcNavy.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text(
            'No work assigned yet',
            style: TextStyle(fontWeight: FontWeight.w700, color: bcTextSecondary),
          ),
          const Text(
            'Contact site admin to get started',
            style: TextStyle(fontSize: 12, color: bcTextSecondary),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(LabourStatus status) {
    switch (status) {
      case LabourStatus.ongoing: return bcInfo;
      case LabourStatus.completed: return bcAmber;
      case LabourStatus.settled: return bcSuccess;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: bcTextSecondary, fontSize: 9, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
