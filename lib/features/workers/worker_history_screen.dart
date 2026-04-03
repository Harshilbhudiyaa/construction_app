import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/worker_model.dart';
import 'package:construction_app/data/repositories/worker_repository.dart';

class WorkerHistoryScreen extends StatefulWidget {
  final WorkerModel worker;
  const WorkerHistoryScreen({super.key, required this.worker});

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
    final workerRepo = context.watch<WorkerRepository>();
    final attendance = workerRepo.getAttendanceForMonth(widget.worker.id, _year, _month);
    final advances = workerRepo.getAdvancesForMonth(widget.worker.id, _year, _month);
    final earned = workerRepo.computeEarnedSalary(widget.worker.id, _year, _month);
    final advanced = workerRepo.getTotalAdvanceForMonth(widget.worker.id, _year, _month);
    final netDue = earned - advanced;
    
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final monthYearFmt = DateFormat('MMMM yyyy');

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
            Text('Payment & Attendance History', style: TextStyle(color: Colors.white.withValues(alpha:0.6), fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Month Selector
          Container(
            color: bcNavy,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                    onPressed: _prevMonth,
                  ),
                  Text(
                    monthYearFmt.format(_selectedDate),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),
          ),

          // KPI Row
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
                    BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _kpiStat('Earned', fmt.format(earned), bcNavy),
                    _vSep(),
                    _kpiStat('Advances', fmt.format(advanced), bcDanger),
                    _vSep(),
                    _kpiStat('Net Due', fmt.format(netDue), bcSuccess),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // Summary Detail
                _sectionHeader('Month Summary'),
                _summaryTile(
                  label: 'Days Worked',
                  value: attendance.where((a) => a.status == AttendanceStatus.present).length.toString(),
                  icon: Icons.calendar_month_rounded,
                  color: bcInfo,
                ),
                _summaryTile(
                  label: 'Half Days',
                  value: attendance.where((a) => a.status == AttendanceStatus.halfDay).length.toString(),
                  icon: Icons.timelapse_rounded,
                  color: bcAmber,
                ),
                const SizedBox(height: 24),

                // Monthly Calendar
                _sectionHeader('Monthly Calendar'),
                _MonthlyCalendar(
                  year: _year,
                  month: _month,
                  attendance: attendance,
                ),

                const SizedBox(height: 24),

                // Attendance Log
                _sectionHeader('Attendance Log'),
                if (attendance.isEmpty)
                  _emptyState('No attendance marked for this month')
                else
                  ...attendance.map((a) => _attendanceLogTile(a)),
 
                const SizedBox(height: 24),
 
                 // Advances Log
                _sectionHeader('Advances Taken'),
                if (advances.isEmpty)
                  _emptyState('No advances taken this month')
                else
                  ...advances.map((a) => _advanceLogTile(a, fmt)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 4),
    child: Text(title.toUpperCase(), 
      style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
  );
 
   Widget _kpiStat(String label, String value, Color color) => Column(
    children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600)),
    ],
  );
 
   Widget _vSep() => Container(width: 1, height: 30, color: const Color(0xFFF1F5F9));
 
   Widget _summaryTile({required String label, required String value, required IconData icon, required Color color}) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha:0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 15)),
      ],
    ),
   );
 
   Widget _attendanceLogTile(AttendanceRecord a) {
    Color statusColor;
    IconData statusIcon;
    switch (a.status) {
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 38,
            child: Column(
              children: [
                Text(DateFormat('dd').format(a.date), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 14)),
                Text(DateFormat('EEE').format(a.date).toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: const Color(0xFFF1F5F9)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(a.status.displayName, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          Icon(statusIcon, color: statusColor, size: 20),
        ],
      ),
    );
   }
 
   Widget _advanceLogTile(WorkerAdvance a, NumberFormat fmt) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bcDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_downward_rounded, color: bcDanger, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fmt.format(a.amount), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 2),
              Text(DateFormat('d MMM yyyy').format(a.date), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (a.remarks != null)
          Container(
            constraints: const BoxConstraints(maxWidth: 100),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Text(a.remarks!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
    ),
  );
 
   Widget _emptyState(String msg) => Container(
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

class _MonthlyCalendar extends StatelessWidget {
  final int year;
  final int month;
  final List<AttendanceRecord> attendance;

  const _MonthlyCalendar({
    required this.year,
    required this.month,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday; // 1=Mon, 7=Sun

    // Map status by day for fast lookup
    final Map<int, AttendanceStatus> statusMap = {
      for (var record in attendance) record.date.day: record.status
    };

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
          // Weekday header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((w) => Expanded(
              child: Center(
                child: Text(w, style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w800, fontSize: 10)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          // Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemCount: 42, // Max grid size (6 rows of 7 days)
            itemBuilder: (context, i) {
              // Adjust index for first week start: (weekday-1) for Monday start
              final dayIndex = i - (firstWeekday - 1);
              if (dayIndex < 0 || dayIndex >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final dayNum = dayIndex + 1;
              final status = statusMap[dayNum];
              
              Color bgColor = Colors.transparent;
              Color textColor = bcNavy;
              double opacity = 0.08;

              if (status == AttendanceStatus.present) {
                bgColor = bcSuccess;
                textColor = Colors.white;
                opacity = 1.0;
              } else if (status == AttendanceStatus.halfDay) {
                bgColor = bcAmber;
                textColor = Colors.white;
                opacity = 1.0;
              } else if (status == AttendanceStatus.absent) {
                bgColor = bcDanger;
                textColor = Colors.white;
                opacity = 1.0;
              }

              return Container(
                decoration: BoxDecoration(
                  color: status != null ? bgColor : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$dayNum',
                    style: TextStyle(
                      color: status != null ? textColor : const Color(0xFF64748B),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
