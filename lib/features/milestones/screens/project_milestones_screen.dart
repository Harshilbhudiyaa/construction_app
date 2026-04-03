import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/milestone_repository.dart';
import 'package:construction_app/data/models/milestone_model.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import '../widgets/add_milestone_sheet.dart';

class ProjectMilestonesScreen extends StatefulWidget {
  const ProjectMilestonesScreen({super.key});

  @override
  State<ProjectMilestonesScreen> createState() =>
      _ProjectMilestonesScreenState();
}

class _ProjectMilestonesScreenState extends State<ProjectMilestonesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final milestoneRepo = context.watch<MilestoneRepository>();

    final overdue = milestoneRepo.getOverdueMilestones();
    final upcoming = milestoneRepo.getUpcomingMilestones();
    final paid = milestoneRepo.milestones.where((m) => m.isPaid).toList()
      ..sort((a, b) =>
          (b.paidOn ?? b.dueDate).compareTo(a.paidOn ?? a.dueDate));

    return ProfessionalPage(
      title: 'Project Milestones',
      subtitle: 'Project performance & payments',
      category: 'PAYMENT MILESTONES',
      headerStats: [
        HeroStatPill(
          label: 'Overdue',
          value: '${overdue.length}',
          icon: Icons.error_outline_rounded,
          color: bcDanger,
          onTap: () => _tab.animateTo(0),
        ),
        HeroStatPill(
          label: 'Upcoming',
          value: '${upcoming.length}',
          icon: Icons.upcoming_rounded,
          color: bcAmber,
          onTap: () => _tab.animateTo(1),
        ),
        HeroStatPill(
          label: 'Paid',
          value: '${paid.length}',
          icon: Icons.check_circle_outline_rounded,
          color: bcSuccess,
          onTap: () => _tab.animateTo(2),
        ),
      ],
      bottom: TabBar(
        controller: _tab,
        indicatorColor: bcAmber,
        labelColor: bcAmber,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        tabs: [
          Tab(text: 'Overdue (${overdue.length})'),
          Tab(text: 'Upcoming (${upcoming.length})'),
          Tab(text: 'Paid (${paid.length})'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: bcAmber,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddMilestoneSheet(),
        ),
        icon: const Icon(Icons.add_rounded, color: bcNavy),
        label: const Text('Add Milestone',
            style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900)),
      ),
      slivers: [
        SliverFillRemaining(
          child: TabBarView(
            controller: _tab,
            children: [
              _MilestoneList(
                  milestones: overdue, emptyMsg: 'No overdue milestones!'),
              _MilestoneList(
                  milestones: upcoming, emptyMsg: 'No upcoming milestones.'),
              _MilestoneList(
                  milestones: paid, emptyMsg: 'No paid milestones yet.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MilestoneList extends StatelessWidget {
  final List<MilestoneModel> milestones;
  final String emptyMsg;
  const _MilestoneList({required this.milestones, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt_rounded,
                size: 64, color: bcTextSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(emptyMsg,
                style: const TextStyle(
                    color: bcTextSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: milestones.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _MilestoneTile(milestone: milestones[i]),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final MilestoneModel milestone;
  const _MilestoneTile({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final Status status;
    final Color color;

    switch (milestone.status) {
      case MilestoneStatus.overdue:
        status = Status.overdue;
        color = bcDanger;
        break;
      case MilestoneStatus.dueSoon:
        status = Status.dueSoon;
        color = bcAmber;
        break;
      case MilestoneStatus.paid:
        status = Status.paid;
        color = bcSuccess;
        break;
      case MilestoneStatus.upcoming:
        status = Status.upcoming;
        color = bcInfo;
        break;
    }

    final milestoneRepo = context.read<MilestoneRepository>();

    return Dismissible(
      key: Key(milestone.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: bcDanger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => milestoneRepo.deleteMilestone(milestone.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status == Status.paid
                      ? Icons.check_circle_rounded
                      : Icons.flag_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: bcTextPrimary),
                    ),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.domain_rounded,
                          size: 12, color: bcTextSecondary),
                      const SizedBox(width: 4),
                      Text(milestone.siteName,
                          style: const TextStyle(
                              color: bcTextSecondary, fontSize: 11)),
                      const Text(' · ',
                          style: TextStyle(color: bcTextSecondary)),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(milestone.dueDate),
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ]),
                    if (milestone.description != null &&
                        milestone.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(milestone.description!,
                            style: const TextStyle(
                                color: bcTextSecondary, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmt.format(milestone.amount),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: bcTextPrimary),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (!milestone.isPaid) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => milestoneRepo.markPaid(milestone.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: bcSuccess.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: bcSuccess.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          'Mark Paid',
                          style: TextStyle(
                              color: bcSuccess,
                              fontSize: 10,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(Status s) {
    switch (s) {
      case Status.overdue:
        return 'OVERDUE';
      case Status.dueSoon:
        return 'DUE SOON';
      case Status.paid:
        return 'PAID';
      case Status.upcoming:
        return 'UPCOMING';
    }
  }
}

enum Status { overdue, dueSoon, paid, upcoming }
