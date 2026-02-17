import 'package:flutter/material.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';

class ApprovalDashboardScreen extends StatelessWidget {
  const ApprovalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Approval Dashboard',
      children: [
        const ProfessionalSectionHeader(
          title: 'Pending Requests',
          subtitle: 'Review and approve material requests',
        ),
        
        // Pending Requests List
        _buildRequestsList(context),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildRequestsList(BuildContext context) {
    // TODO: Fetch from service
    final mockRequests = [
      {
        'id': '1',
        'material': 'Portland Cement',
        'quantity': '100 bags',
        'requestedBy': 'John Doe',
        'site': 'Site A',
        'priority': 'High',
        'date': '2026-02-16',
      },
      {
        'id': '2',
        'material': 'Steel TMT Bars',
        'quantity': '500 kg',
        'requestedBy': 'Jane Smith',
        'site': 'Main Site',
        'priority': 'Medium',
        'date': '2026-02-15',
      },
    ];

    if (mockRequests.isEmpty) {
      return const ProfessionalCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(48.0),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'No Pending Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'All material requests have been processed',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockRequests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = mockRequests[index];
        return _buildRequestCard(context, request);
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, String> request) {
    final priorityColor = _getPriorityColor(request['priority']!);
    
    return ProfessionalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['material']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${request['quantity']}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request['priority']!,
                  style: TextStyle(
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                request['requestedBy']!,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                request['site']!,
                style: const TextStyle(fontSize: 12),
              ),
              const Spacer(),
              Text(
                request['date']!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rejectRequest(context, request['id']!),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveRequest(context, request['id']!),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Urgent':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Medium':
        return Colors.blue;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _approveRequest(BuildContext context, String requestId) {
    // TODO: Approve in service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request approved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectRequest(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Request rejected'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
