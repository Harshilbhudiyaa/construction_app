import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';

class WorkHistoryListScreen extends StatefulWidget {
  const WorkHistoryListScreen({super.key});

  @override
  State<WorkHistoryListScreen> createState() => _WorkHistoryListScreenState();
}

class _WorkHistoryListScreenState extends State<WorkHistoryListScreen> {
  String _searchQuery = '';
  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  final List<Map<String, dynamic>> _history = [
    {
      'date': DateTime.now().subtract(const Duration(hours: 4)),
      'type': 'Concrete Work',
      'site': 'Metropolis Site A',
      'duration': '8h 00m',
      'status': UiStatus.pending,
      'amount': 850,
      'id': 'SESS-9021'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      'type': 'Brick Work',
      'site': 'Metropolis Site A',
      'duration': '8h 30m',
      'status': UiStatus.approved,
      'amount': 900,
      'id': 'SESS-8902'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      'type': 'General Labor',
      'site': 'City Center Mall',
      'duration': '6h 00m',
      'status': UiStatus.approved,
      'amount': 550,
      'id': 'SESS-8841'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 3, hours: 1)),
      'type': 'Concrete Work',
      'site': 'Metropolis Site A',
      'duration': '9h 00m',
      'status': UiStatus.approved,
      'amount': 950,
      'id': 'SESS-8755'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'type': 'Site Cleanup',
      'site': 'City Center Mall',
      'duration': '8h 00m',
      'status': UiStatus.approved,
      'amount': 800,
      'id': 'SESS-8210'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _history.where((s) {
      final q = _searchQuery.toLowerCase();
      return s['type'].toString().toLowerCase().contains(q) ||
             s['site'].toString().toLowerCase().contains(q) ||
             s['id'].toString().toLowerCase().contains(q);
    }).toList();

    return ProfessionalPage(
      title: 'Work History',
      children: [
        const ProfessionalSectionHeader(
          title: 'Session Log',
          subtitle: 'Track your daily work & approvals',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AppSearchField(
            hint: 'Search by work type, site or ID...',
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),

        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(48),
            child: Center(
              child: Column(
                children: [
                   Icon(Icons.history_toggle_off_rounded, size: 48, color: Theme.of(context).disabledColor),
                   const SizedBox(height: 16),
                   Text('No sessions found', style: TextStyle(color: Theme.of(context).disabledColor)),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final session = filtered[index];
              return StaggeredAnimation(
                index: index,
                child: _SessionCard(session: session, currency: _currency),
              );
            },
          ),
          
        const SizedBox(height: 100),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final NumberFormat currency;

  const _SessionCard({required this.session, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = session['date'] as DateTime;
    final status = session['status'] as UiStatus;

    return ProfessionalCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.handyman_rounded, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['type'],
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session['site'],
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MMM d, y').format(date),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusChip(status: status),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(context, Icons.schedule_rounded, session['duration']),
              _buildMetric(context, Icons.confirmation_number_outlined, session['id']),
              if (session['amount'] != null)
                 Text(
                   currency.format(session['amount']),
                   style: TextStyle(
                     color: theme.colorScheme.primary,
                     fontWeight: FontWeight.w900,
                     fontSize: 16,
                   ),
                 ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Monospace', // Slight tech feel for ID/Duration
          ),
        ),
      ],
    );
  }
}
