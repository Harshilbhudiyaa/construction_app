import 'package:flutter/material.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/theme/design_system.dart';
import 'package:construction_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Settings',
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSection(
                context,
                title: 'General',
                children: [
                   ListTile(
                    leading: const Icon(Icons.palette_rounded, color: DesignSystem.deepNavy),
                    title: const Text('Appearance'),
                    subtitle: const Text('Customize theme and layout'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_rounded, color: DesignSystem.deepNavy),
                    title: const Text('Notifications'),
                    subtitle: const Text('Manage alerts and updates'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                context,
                title: 'Account',
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded, color: DesignSystem.deepNavy),
                    title: const Text('Profile'),
                    subtitle: const Text('Manage your account details'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: DesignSystem.error),
                    title: const Text('Logout', style: TextStyle(color: DesignSystem.error)),
                    onTap: () => context.read<AuthService>().logout(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
