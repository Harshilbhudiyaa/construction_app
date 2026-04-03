import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/data/repositories/calculation_repository.dart';
import 'package:construction_app/data/models/calculation_history_model.dart';

class CalculationHistoryScreen extends StatelessWidget {
  const CalculationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<CalculationRepository>();
    final history = repo.history;

    return ProfessionalBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            const SmartConstructionSliverAppBar(
              title: 'Calculation History',
              subtitle: 'Saved engineering estimates',
              category: 'SmartConstruction LOGS',
              isFull: false,
            ),
          ],
          body: history.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return _HistoryItemCard(entry: history[index]);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: bcNavy.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text(
            'No saved calculations found',
            style: TextStyle(color: bcTextSecondary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Calculations you save will appear here',
            style: TextStyle(color: bcTextSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final CalculationHistory entry;

  const _HistoryItemCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final nf = NumberFormat('#,##0.###');

    return ProfessionalCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bcNavy.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.category.toUpperCase(),
                  style: const TextStyle(color: bcNavy, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                Text(
                  dateFormat.format(entry.timestamp),
                  style: const TextStyle(color: bcTextSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(color: bcNavy, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        context.read<CalculationRepository>().deleteCalculation(entry.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: entry.data.entries.map((e) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.key, style: const TextStyle(color: bcTextSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text(e.value, style: const TextStyle(color: bcNavy, fontSize: 13, fontWeight: FontWeight.w800)),
                      ],
                    );
                  }).toList(),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL ESTIMATE', style: TextStyle(color: bcTextSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(
                      '₹ ${nf.format(entry.totalCost)}',
                      style: const TextStyle(color: bcNavy, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
