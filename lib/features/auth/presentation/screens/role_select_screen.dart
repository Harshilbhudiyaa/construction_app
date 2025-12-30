import 'package:flutter/material.dart';
import '../../../../app/routes.dart';

enum AppRole { worker, engineer, contractor }

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget roleCard({
      required String title,
      required String subtitle,
      required IconData icon,
      required AppRole role,
    }) {
      return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.login,
              arguments: role,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Choose how you want to use the app.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 8),
          roleCard(
            title: 'Worker',
            subtitle: 'Start/stop work, view earnings, history',
            icon: Icons.engineering_rounded,
            role: AppRole.worker,
          ),
          roleCard(
            title: 'Site Engineer',
            subtitle: 'Approvals, blocks, inventory, trucks',
            icon: Icons.rule_folder_rounded,
            role: AppRole.engineer,
          ),
          roleCard(
            title: 'Contractor',
            subtitle: 'Full control: payments, analytics, audits',
            icon: Icons.admin_panel_settings_rounded,
            role: AppRole.contractor,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
