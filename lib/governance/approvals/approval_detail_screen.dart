import 'package:flutter/material.dart';
import 'approvals_queue_screen.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/confirm_sheet.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/approval_service.dart';
import 'package:construction_app/governance/approvals/models/action_request.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/services/mock_worker_service.dart';
import 'package:construction_app/services/mock_tool_service.dart';
import 'package:construction_app/services/mock_machine_service.dart';
import 'package:construction_app/services/inventory_service.dart';
import 'package:construction_app/services/mock_notification_service.dart';

class ApprovalDetailScreen extends StatefulWidget {
  final ActionRequest request;

  const ApprovalDetailScreen({super.key, required this.request});

  @override
  State<ApprovalDetailScreen> createState() => _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends State<ApprovalDetailScreen> {
  late ActionRequest _request = widget.request;

  UiStatus _toUi(ApprovalStatus s) {
    switch (s) {
      case ApprovalStatus.pending: return UiStatus.pending;
      case ApprovalStatus.approved: return UiStatus.approved;
      case ApprovalStatus.rejected: return UiStatus.rejected;
    }
  }

  Future<void> _approve() async {
    final ok = await showConfirmSheet(
      context: context,
      title: 'Authorize Request',
      message: 'Confirm to execute this ${_request.entityType} ${_request.action.name} operation.',
      confirmText: 'Verify & Authorize',
    );
    if (!ok) return;

    await Provider.of<ApprovalService>(context, listen: false).processRequest(
      _request.id, 
      ApprovalStatus.approved,
      workerService: Provider.of<MockWorkerService>(context, listen: false),
      toolService: Provider.of<MockToolService>(context, listen: false),
      machineService: Provider.of<MockMachineService>(context, listen: false),
      inventoryService: Provider.of<InventoryService>(context, listen: false),
      notificationService: Provider.of<MockNotificationService>(context, listen: false),
    );
    
    if (mounted) Navigator.pop(context);
  }

  Future<void> _reject() async {
    final remark = await _showRejectDialog();
    if (remark == null || remark.isEmpty) return;

    await Provider.of<ApprovalService>(context, listen: false)
        .processRequest(_request.id, ApprovalStatus.rejected, 
            remark: remark, 
            notificationService: Provider.of<MockNotificationService>(context, listen: false));
    
    if (mounted) Navigator.pop(context);
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter reason for rejection...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('REJECT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Review Signature',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.1)),
                  ),
                  child: Icon(_getEntityIcon(_request.entityType), color: const Color(0xFF1A237E), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_request.action.name.toUpperCase()} ${_request.entityType.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepBlue1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Requested by ${_request.requesterName} • ${_request.siteId}',
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: _request.status),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Session Verification',
          subtitle: 'Verified session history',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _kv('Operation Type', _request.action.name.toUpperCase(), icon: Icons.assignment_rounded),
                const Divider(height: 32, color: Color(0xFFEEEEEE)),
                _kv('Target Registry', _request.entityType.toUpperCase(), icon: Icons.storage_rounded),
                const Divider(height: 32, color: Color(0xFFEEEEEE)),
                _kv('Submission Time', DateFormat('MMM dd, yyyy HH:mm').format(_request.createdAt), icon: Icons.schedule_rounded),
                const Divider(height: 32, color: Color(0xFFEEEEEE)),
                _kv('Registry Site', _request.siteId, icon: Icons.location_on_rounded, isHighlighted: true),
                const Divider(height: 32, color: Color(0xFFEEEEEE)),
                _kv('Request Token', _request.id, icon: Icons.fingerprint_rounded),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Payload Review',
          subtitle: 'Specific data changes being requested',
        ),
        _buildPayloadSection(),

        const ProfessionalSectionHeader(
          title: 'Engineering Decisions',
          subtitle: 'Sign-off on worklog accuracy',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _request.status == ApprovalStatus.approved ? null : _reject,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: Colors.red[800],
                    side: BorderSide(color: Colors.red[300]!),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: const Text('Decline Request', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _request.status == ApprovalStatus.approved ? null : _approve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlue1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text('Authorize', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _kv(String k, String v, {IconData? icon, bool isHighlighted = false}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: const Color(0xFF78909C)),
          const SizedBox(width: 12),
        ],
        Text(k, style: const TextStyle(color: Color(0xFF546E7A), fontSize: 13, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text(
          v,
          style: TextStyle(
            color: isHighlighted ? const Color(0xFF1976D2) : const Color(0xFF1A237E),
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPayloadSection() {
    if (_request.payload.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ProfessionalCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: _request.payload.entries.map((e) {
            final isLast = e.key == _request.payload.keys.last;
            return Column(
              children: [
                _kv(_capitalize(e.key), _formatValue(e.value)),
                if (!isLast) const Divider(height: 32, color: Color(0xFFEEEEEE)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _formatValue(dynamic v) {
    if (v == null) return 'N/A';
    if (v is List) return v.join(', ');
    if (v is bool) return v ? 'YES' : 'NO';
    return v.toString();
  }

  IconData _getEntityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'worker': return Icons.badge_rounded;
      case 'tool': return Icons.build_circle_rounded;
      case 'machine': return Icons.precision_manufacturing_rounded;
      case 'material': return Icons.inventory_2_rounded;
      default: return Icons.help_outline_rounded;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final ApprovalStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    String label = 'UNKNOWN';
    switch (status) {
      case ApprovalStatus.pending: color = Colors.orangeAccent; label = 'PENDING'; break;
      case ApprovalStatus.approved: color = Colors.greenAccent; label = 'APPROVED'; break;
      case ApprovalStatus.rejected: color = Colors.redAccent; label = 'REJECTED'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}
