import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/worker_model.dart';
import 'package:construction_app/data/repositories/worker_repository.dart';

class WorkerHistoryScreen extends StatefulWidget {
  final WorkerModel worker;
  final bool isEmbedded;
  const WorkerHistoryScreen({super.key, required this.worker, this.isEmbedded = false});

  @override
  State<WorkerHistoryScreen> createState() => _WorkerHistoryScreenState();
}

class _WorkerHistoryScreenState extends State<WorkerHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = _selectedDate.year;
    _month = _selectedDate.month;
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
      _selectedDate = DateTime(_year, _month);
    });
  }

  void _prevMonth() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
      _selectedDate = DateTime(_year, _month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<WorkerRepository>();
    final attendance = repo.getAttendanceForMonth(widget.worker.id, _year, _month);
    final advances = repo.getAdvancesForMonth(widget.worker.id, _year, _month);
    final earned = repo.computeEarnedSalary(widget.worker.id, _year, _month);
    final paid = repo.getTotalAdvanceForMonth(widget.worker.id, _year, _month);
    final pending = earned - paid;
    final presentCount = attendance.where((a) => a.status == AttendanceStatus.present).length;
    final halfDayCount = attendance.where((a) => a.status == AttendanceStatus.halfDay).length;
    final absentCount = attendance.where((a) => a.status == AttendanceStatus.absent).length;
    final totalUnits = presentCount + (halfDayCount * 0.5);
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final monthYearFmt = DateFormat('MMMM yyyy');
    final ledgerEntries = _buildLedger(attendance, advances);

    final content = Column(
      children: [
        Container(
          color: bcNavy,
          padding: EdgeInsets.fromLTRB(16, widget.isEmbedded ? 16 : 0, 16, 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                      onPressed: _prevMonth,
                    ),
                    Column(
                      children: [
                        Text(monthYearFmt.format(_selectedDate), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                        const SizedBox(height: 2),
                        Text('Monthly payment & attendance history', style: TextStyle(color: Colors.white.withValues(alpha: 0.62), fontSize: 11)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
              if (widget.isEmbedded) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _HeroSummaryCard(label: 'Earned', value: fmt.format(earned), color: Colors.white)),
                    const SizedBox(width: 10),
                    Expanded(child: _HeroSummaryCard(label: 'Paid', value: fmt.format(paid), color: bcAmber)),
                    const SizedBox(width: 10),
                    Expanded(child: _HeroSummaryCard(label: 'Pending', value: fmt.format(pending), color: pending > 0 ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC))),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (!widget.isEmbedded)
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 22, offset: const Offset(0, 12)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _KpiStat('Earned', fmt.format(earned), bcNavy),
                    _VerticalSep(),
                    _KpiStat('Paid', fmt.format(paid), bcAmber),
                    _VerticalSep(),
                    _KpiStat('Pending', fmt.format(pending), pending > 0 ? bcDanger : bcSuccess),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, widget.isEmbedded ? 16 : 8, 16, 32),
            children: [
              _sectionHeader('Month Summary'),
              Row(
                children: [
                  Expanded(child: _SummaryTile(label: 'Present Days', value: '$presentCount', icon: Icons.check_circle_rounded, color: bcSuccess)),
                  const SizedBox(width: 10),
                  Expanded(child: _SummaryTile(label: 'Half Days', value: '$halfDayCount', icon: Icons.timelapse_rounded, color: bcAmber)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _SummaryTile(label: 'Absent', value: '$absentCount', icon: Icons.cancel_rounded, color: bcDanger)),
                  const SizedBox(width: 10),
                  Expanded(child: _SummaryTile(label: 'Attendance Units', value: totalUnits.toStringAsFixed(totalUnits % 1 == 0 ? 0 : 1), icon: Icons.calendar_month_rounded, color: bcInfo)),
                ],
              ),
              const SizedBox(height: 24),
              _sectionHeader('Monthly Calendar'),
              _MonthlyCalendar(year: _year, month: _month, attendance: attendance),
              const SizedBox(height: 24),
              _sectionHeader('Payment Ledger'),
              if (ledgerEntries.isEmpty)
                _emptyState('No attendance or payment history for this month')
              else
                ...ledgerEntries.map((entry) => _LedgerTile(entry: entry, fmt: fmt)),
              const SizedBox(height: 24),
              _sectionHeader('Attendance Log'),
              if (attendance.isEmpty)
                _emptyState('No attendance marked for this month')
              else
                ...attendance.map((a) => _AttendanceLogTile(a)),
              const SizedBox(height: 24),
              _sectionHeader('Payment / Advance Entries'),
              if (advances.isEmpty)
                _emptyState('No payment entries recorded this month')
              else
                ...advances.map((a) => _AdvanceLogTile(a, fmt)),
            ],
          ),
        ),
      ],
    );

    if (widget.isEmbedded) return content;

    return Scaffold(
      backgroundColor: bcSurface,
      appBar: AppBar(
        backgroundColor: bcNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.worker.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            Text('Payment & Attendance History', style: TextStyle(color: Colors.white.withValues(alpha: 0.64), fontSize: 11)),
          ],
        ),
      ),
      body: content,
    );
  }

  List<_LedgerEntry> _buildLedger(List<AttendanceRecord> attendance, List<WorkerAdvance> advances) {
    final entries = <_LedgerEntry>[];

    for (final item in attendance) {
      entries.add(_LedgerEntry(
        date: item.date,
        type: _LedgerType.attendance,
        title: 'Attendance marked',
        subtitle: item.status.displayName,
        amount: null,
      ));
    }

    for (final item in advances) {
      entries.add(_LedgerEntry(
        date: item.date,
        type: _LedgerType.payment,
        title: 'Payment recorded',
        subtitle: item.remarks?.trim().isNotEmpty == true ? item.remarks! : 'Amount paid to worker',
        amount: item.amount,
      ));
    }

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 4),
    child: Text(title.toUpperCase(), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
  );
}

class _HeroSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HeroSummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _KpiStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _KpiStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _VerticalSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 30, color: const Color(0xFFF1F5F9));
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 12))),
          Text(value, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 15)),
        ],
      ),
    );
  }
}

class _LedgerTile extends StatelessWidget {
  final _LedgerEntry entry;
  final NumberFormat fmt;
  const _LedgerTile({required this.entry, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isPayment = entry.type == _LedgerType.payment;
    final color = isPayment ? bcAmber : _attendanceColor(entry.subtitle);
    final icon = isPayment ? Icons.payments_rounded : _attendanceIcon(entry.subtitle);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 2),
                Text(entry.subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                const SizedBox(height: 2),
                Text(DateFormat('d MMM yyyy').format(entry.date), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (entry.amount != null)
            Text(fmt.format(entry.amount), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }

  Color _attendanceColor(String subtitle) {
    if (subtitle.toLowerCase().contains('present')) return bcSuccess;
    if (subtitle.toLowerCase().contains('half')) return bcAmber;
    return bcDanger;
  }

  IconData _attendanceIcon(String subtitle) {
    if (subtitle.toLowerCase().contains('present')) return Icons.check_circle_rounded;
    if (subtitle.toLowerCase().contains('half')) return Icons.timelapse_rounded;
    return Icons.cancel_rounded;
  }
}

class _AttendanceLogTile extends StatelessWidget {
  final AttendanceRecord record;
  const _AttendanceLogTile(this.record);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    switch (record.status) {
      case AttendanceStatus.present:
        statusColor = bcSuccess;
        statusIcon = Icons.check_circle_rounded;
        break;
      case AttendanceStatus.halfDay:
        statusColor = bcAmber;
        statusIcon = Icons.timelapse_rounded;
        break;
      case AttendanceStatus.absent:
        statusColor = bcDanger;
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Text(DateFormat('dd').format(record.date), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 14)),
                Text(DateFormat('EEE').format(record.date).toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: const Color(0xFFF1F5F9)),
          const SizedBox(width: 12),
          Expanded(child: Text(record.status.displayName, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13))),
          Icon(statusIcon, color: statusColor, size: 20),
        ],
      ),
    );
  }
}

class _AdvanceLogTile extends StatelessWidget {
  final WorkerAdvance advance;
  final NumberFormat fmt;
  const _AdvanceLogTile(this.advance, this.fmt);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bcAmber.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.payments_rounded, color: bcAmber, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fmt.format(advance.amount), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 2),
                Text(DateFormat('d MMM yyyy').format(advance.date), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500)),
                if (advance.remarks?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(advance.remarks!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyCalendar extends StatelessWidget {
  final int year;
  final int month;
  final List<AttendanceRecord> attendance;
  const _MonthlyCalendar({required this.year, required this.month, required this.attendance});

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;
    final statusMap = {for (var record in attendance) record.date.day: record.status};
    final weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((w) => Expanded(child: Center(child: Text(w, style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w800, fontSize: 10))))).toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemCount: 42,
            itemBuilder: (context, i) {
              final dayIndex = i - (firstWeekday - 1);
              if (dayIndex < 0 || dayIndex >= daysInMonth) return const SizedBox.shrink();
              final dayNum = dayIndex + 1;
              final status = statusMap[dayNum];
              Color bgColor = const Color(0xFFF8FAFC);
              Color textColor = bcNavy;
              if (status == AttendanceStatus.present) {
                bgColor = bcSuccess;
                textColor = Colors.white;
              } else if (status == AttendanceStatus.halfDay) {
                bgColor = bcAmber;
                textColor = Colors.white;
              } else if (status == AttendanceStatus.absent) {
                bgColor = bcDanger;
                textColor = Colors.white;
              }
              return Container(
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text('$dayNum', style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: const [
              _LegendDot(color: bcSuccess, label: 'Present'),
              _LegendDot(color: bcAmber, label: 'Half Day'),
              _LegendDot(color: bcDanger, label: 'Absent'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String msg;
  const _EmptyState(this.msg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.history_rounded, color: Color(0xFFCBD5E1), size: 42),
            const SizedBox(height: 12),
            Text(msg, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

Widget _emptyState(String msg) => _EmptyState(msg);

enum _LedgerType { attendance, payment }

class _LedgerEntry {
  final DateTime date;
  final _LedgerType type;
  final String title;
  final String subtitle;
  final double? amount;

  _LedgerEntry({required this.date, required this.type, required this.title, required this.subtitle, this.amount});
}
