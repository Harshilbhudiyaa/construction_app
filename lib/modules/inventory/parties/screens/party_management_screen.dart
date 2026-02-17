import 'package:flutter/material.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/theme/design_system.dart';
import 'package:construction_app/services/party_service.dart';
import 'package:construction_app/modules/inventory/parties/models/party_model.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
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
          icon: Icon(Icons.add_circle_outline_rounded, color: DesignSystem.electricBlue),
          tooltip: 'Add Party',
        ),
      ],
      children: [
        StreamBuilder<List<PartyModel>>(
          stream: partyService.getPartiesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: DesignSystem.electricBlue));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: DesignSystem.error)));
            }
            final parties = snapshot.data ?? [];
            if (parties.isEmpty) {
              return const EmptyState(
                icon: Icons.business_rounded,
                title: 'No parties added yet',
                message: 'Add suppliers or clients to start tracking transactions.',
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
                    useGlass: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PartyCardScreen(party: party)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: DesignSystem.deepNavy.withOpacity(0.1),
                        child: Text(
                          party.name.isNotEmpty ? party.name[0].toUpperCase() : '?',
                          style: TextStyle(color: DesignSystem.deepNavy, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(party.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          if (party.contactNumber != null && party.contactNumber!.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.phone_rounded, size: 14, color: DesignSystem.coolGrey),
                                const SizedBox(width: 4),
                                Text(party.contactNumber!, style: TextStyle(color: DesignSystem.coolGrey, fontSize: 13)),
                              ],
                            ),
                          if (party.category != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                party.category.displayName.toUpperCase(),
                                style: TextStyle(color: DesignSystem.electricBlue, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit_note_rounded, color: DesignSystem.coolGrey),
                        tooltip: 'Edit Party',
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
