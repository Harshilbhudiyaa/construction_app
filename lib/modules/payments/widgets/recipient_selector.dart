import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/mock_engineer_service.dart';

class RecipientSelector extends StatefulWidget {
  final String category; // 'engineer', 'worker', 'inventory'
  final Function(String id, String name, Map<String, dynamic> details) onRecipientSelected;
  final String? initialRecipientId;

  const RecipientSelector({
    super.key,
    required this.category,
    required this.onRecipientSelected,
    this.initialRecipientId,
  });
  
  static List<Map<String, dynamic>> getRecipients(BuildContext context, String category) {
    switch (category) {
      case 'engineer':
        final engineerService = Provider.of<MockEngineerService>(context, listen: false);
        return engineerService.engineers.map((eng) => <String, dynamic>{
          'id': eng.id,
          'name': eng.name,
          'subtitle': '${eng.role.displayName} • ${eng.assignedSite ?? 'No Site'}',
          'details': <String, dynamic>{
            'role': eng.role.displayName,
            'site': eng.assignedSite ?? 'No Site',
            'phone': eng.phone ?? 'No Phone',
            'engineerId': eng.id,
          },
        }).toList();
      
      case 'worker':
        return [
          <String, dynamic>{
            'id': 'WRK-101',
            'name': 'Ramesh Singh',
            'subtitle': 'Mason • Metropolis Heights',
            'details': <String, dynamic>{
              'role': 'Mason', 
              'site': 'Metropolis Heights', 
              'dailyWage': 800.0,
            },
          },
          <String, dynamic>{
            'id': 'WRK-102',
            'name': 'Suresh Kumar',
            'subtitle': 'Carpenter • Skyline Tower',
            'details': <String, dynamic>{
              'role': 'Carpenter', 
              'site': 'Skyline Tower', 
              'dailyWage': 750.0,
            },
          },
          <String, dynamic>{
            'id': 'WRK-103',
            'name': 'Vijay Patil',
            'subtitle': 'Laborer • Central Plaza',
            'details': <String, dynamic>{
              'role': 'Laborer', 
              'site': 'Central Plaza', 
              'dailyWage': 650.0,
            },
          },
        ];
      
      case 'inventory':
        return [
          <String, dynamic>{
            'id': 'SUP-001',
            'name': 'Steel Traders Ltd',
            'subtitle': 'Steel & Metal Supplier',
            'details': <String, dynamic>{
              'itemType': 'Steel', 
              'unitPrice': 370.0,
              'unit': 'kg',
              'contact': '+91 98765 43210',
            },
          },
          <String, dynamic>{
            'id': 'SUP-002',
            'name': 'Cement Suppliers Co',
            'subtitle': 'Cement & Concrete',
            'details': <String, dynamic>{
              'itemType': 'Cement', 
              'unitPrice': 450.0,
              'unit': 'bag',
              'contact': '+91 98765 43211',
            },
          },
          <String, dynamic>{
            'id': 'SUP-003',
            'name': 'Building Materials Hub',
            'subtitle': 'General Building Materials',
            'details': <String, dynamic>{
              'itemType': 'Bricks', 
              'unitPrice': 12.0,
              'unit': 'pcs',
              'contact': '+91 98765 43212',
            },
          },
        ];
      
      default:
        return [];
    }
  }

  static Map<String, dynamic>? getRecipientDetails(BuildContext context, String category, String? id) {
    if (id == null) return null;
    final recipients = getRecipients(context, category);
    try {
      return recipients.firstWhere((r) => r['id'] == id)['details'];
    } catch (e) {
      return null;
    }
  }

  @override
  State<RecipientSelector> createState() => _RecipientSelectorState();
}

class _RecipientSelectorState extends State<RecipientSelector> {
  String? _selectedId;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialRecipientId;
  }



  String _getCategoryLabel() {
    switch (widget.category) {
      case 'engineer':
        return 'Select Engineer';
      case 'worker':
        return 'Select Worker';
      case 'inventory':
        return 'Select Supplier';
      default:
        return 'Select Recipient';
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipients = RecipientSelector.getRecipients(context, widget.category);
    final filtered = recipients.where((r) {
      return r['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             r['subtitle'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final selected = recipients.firstWhere(
      (r) => r['id'] == _selectedId,
      orElse: () => <String, dynamic>{'id': null, 'name': 'Not selected', 'subtitle': ''},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getCategoryLabel(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        InkWell(
          onTap: () => _showRecipientPicker(context, filtered),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedId != null 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: _selectedId != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedId != null ? Icons.check_circle : Icons.person_search_rounded,
                  color: _selectedId != null 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected['name'],
                        style: TextStyle(
                          color: _selectedId != null 
                              ? Theme.of(context).colorScheme.primary 
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selected['subtitle'] != '') ...[
                        const SizedBox(height: 2),
                        Text(
                          selected['subtitle'],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRecipientPicker(BuildContext context, List<Map<String, dynamic>> recipients) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  children: [
                    Text(
                      _getCategoryLabel(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 15),
                        prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), size: 22),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: recipients.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final recipient = recipients[index];
                    final isSelected = _selectedId == recipient['id'];
                    
                    return InkWell(
                      onTap: () {
                        this.setState(() => _selectedId = recipient['id']);
                        widget.onRecipientSelected(
                          recipient['id'],
                          recipient['name'],
                          recipient['details'],
                        );
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary 
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  recipient['name'].toString().substring(0, 1),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipient['name'],
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recipient['subtitle'],
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected) 
                              Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
