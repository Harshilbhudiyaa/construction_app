import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../engineer/engineer_shell.dart';
import '../engineer/models/engineer_model.dart';
import '../../app/ui/widgets/status_chip.dart';
import '../../core/services/mock_engineer_service.dart';
import '../engineer/engineer_form_screen.dart';

class SiteAccessScreen extends StatelessWidget {
  const SiteAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Site Access',
      actions: [
         IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EngineerFormScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          tooltip: 'Add Site Engineer',
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a Site Engineer to simulate login:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              
              Consumer<MockEngineerService>(
                builder: (context, service, child) {
                  final engineers = service.engineers;
                  
                  if (engineers.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No personnel found.\nAdd one to get started.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    );
                  }

                  return Column(
                     children: engineers.map((e) => _buildEngineerTile(context, e)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEngineerTile(BuildContext context, EngineerModel engineer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ProfessionalCard(
        useGlass: true,
        padding: const EdgeInsets.all(4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.deepBlue2,
            child: Text(engineer.name[0], style: const TextStyle(color: Colors.white)),
          ),
          title: Text(engineer.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(engineer.role.displayName, style: TextStyle(color: Colors.white.withOpacity(0.7))),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusChip(
                status: engineer.isActive ? UiStatus.ok : UiStatus.stop,
                labelOverride: engineer.isActive ? 'ACTIVE' : 'OFFLINE',
              ),
              const SizedBox(width: 8),
              
              // Edit Button
              IconButton(
                icon: Icon(Icons.edit_rounded, color: Colors.white.withOpacity(0.7), size: 20),
                tooltip: 'Edit Profile',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EngineerFormScreen(engineer: engineer),
                    ),
                  );
                },
              ),
              
              // Login Button
              if (engineer.isActive)
                IconButton(
                  icon: const Icon(Icons.login_rounded, color: Colors.greenAccent),
                  tooltip: 'Login as ${engineer.name}',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EngineerShell(
                          engineerId: engineer.id,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
