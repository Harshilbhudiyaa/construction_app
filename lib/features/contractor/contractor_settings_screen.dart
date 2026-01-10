import 'package:flutter/material.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class ContractorSettingsScreen extends StatelessWidget {
  const ContractorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Settings',
      children: [
        const ProfessionalSectionHeader(
          title: 'Account',
          subtitle: 'Manage your profile and preferences',
        ),
        _SettingsGroup(
          items: [
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              subtitle: 'Change name, email, or photo',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'Manage alert preferences',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.security_rounded,
              title: 'Security',
              subtitle: 'Password and biometric settings',
              onTap: () {},
            ),
          ],
        ),
        const ProfessionalSectionHeader(
          title: 'System',
          subtitle: 'App configuration and info',
        ),
        _SettingsGroup(
          items: [
            _SettingsTile(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: 'English (US)',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'Appearance',
              subtitle: 'System Default',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'About App',
              subtitle: 'Version 2.0.5',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsTile> items;

  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ProfessionalCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                e.value,
                if (!isLast)
                  Divider(height: 1, indent: 64, color: Colors.grey[200]),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.deepBlue1.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.deepBlue1, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
