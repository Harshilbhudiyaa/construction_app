import 'package:flutter/material.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/services/party_service.dart';
import 'models/party_model.dart';
import 'party_form_screen.dart';
import 'party_card_screen.dart';

class PartyManagementScreen extends StatelessWidget {
  const PartyManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final partyService = PartyService();

    return ProfessionalPage(
      title: 'Party Management',
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PartyFormScreen()),
          ),
          icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.blueAccent),
        ),
      ],
      children: [
        StreamBuilder<List<PartyModel>>(
          stream: partyService.getPartiesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
            }
            final parties = snapshot.data ?? [];
            if (parties.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    Icon(Icons.business_rounded, size: 64, color: AppColors.steelBlue.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text('No parties added yet', style: TextStyle(color: AppColors.steelBlue)),
                  ],
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: parties.length,
              itemBuilder: (context, index) {
                final party = parties[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ProfessionalCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PartyCardScreen(party: party)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.deepBlue.withOpacity(0.1),
                        child: Text(party.name[0].toUpperCase(), style: const TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(party.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(party.contactNumber ?? 'No contact info'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_note_rounded, color: AppColors.steelBlue),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PartyFormScreen(party: party)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
