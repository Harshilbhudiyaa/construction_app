import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';

class WorkTypeSelectScreen extends StatelessWidget {
  const WorkTypeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workTypes = [
      {'name': 'Concrete Work', 'icon': Icons.architecture_rounded, 'color': Colors.blueAccent},
      {'name': 'Brick / Block Work', 'icon': Icons.grid_view_rounded, 'color': Colors.orangeAccent},
      {'name': 'Plumbing', 'icon': Icons.plumbing_rounded, 'color': Colors.cyanAccent},
      {'name': 'Electrical', 'icon': Icons.electrical_services_rounded, 'color': Colors.yellowAccent},
      {'name': 'Carpentry', 'icon': Icons.carpenter_rounded, 'color': Colors.brown},
      {'name': 'General Labor', 'icon': Icons.engineering_rounded, 'color': Colors.grey},
    ];

    return ProfessionalPage(
      title: 'Start Work',
      children: [
        const ProfessionalSectionHeader(
          title: 'Select Work Nature',
          subtitle: 'What are you working on today?',
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: workTypes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final type = workTypes[index];
              return StaggeredAnimation(
                index: index,
                child: _WorkTypeCard(
                  name: type['name'] as String,
                  icon: type['icon'] as IconData,
                  color: type['color'] as Color,
                  onTap: () {
                    Navigator.pop(context, type['name']);
                  },
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 100),
      ],
    );
  }
}

class _WorkTypeCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WorkTypeCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ProfessionalCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
