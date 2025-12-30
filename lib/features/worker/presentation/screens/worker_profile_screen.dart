import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/confirm_sheet.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ramesh Kumar',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 2),
                          Text('Worker • Site A (demo)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(
            title: 'Account',
            subtitle: 'Settings and support',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.lock_rounded),
                    title: Text('Change Password'),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.help_outline_rounded),
                    title: Text('Help & Support'),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.logout_rounded),
                    title: Text('Logout'),
                    trailing: Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final ok = await showConfirmSheet(
                        context: context,
                        title: 'Logout?',
                        message:
                            'You will be returned to the login screen (UI-only for now).',
                        confirmText: 'Logout',
                      );
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out (UI-only)')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
