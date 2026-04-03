import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/core/theme/design_system.dart';

class MaterialSearchDelegate extends SearchDelegate<ConstructionMaterial?> {
  final BuildContext context;
  
  MaterialSearchDelegate(this.context);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
             query = '';
             showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResultList(context);
  }
  
  Widget _buildResultList(BuildContext context) {
    final inventoryService = this.context.read<InventoryRepository>();
    
    return StreamBuilder<List<dynamic>>(
      stream: inventoryService.getMaterialsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
           return const Center(child: CircularProgressIndicator());
        }
        
        final materials = snapshot.data as List<ConstructionMaterial>;
        final queryLower = query.toLowerCase();
        
        final results = materials.where((m) {
          return m.name.toLowerCase().contains(queryLower) ||
                 m.subType.toLowerCase().contains(queryLower) ||
                 m.category.displayName.toLowerCase().contains(queryLower);
        }).toList();
        
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No materials found for "$query"',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final material = results[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: DesignSystem.electricBlue.withValues(alpha: 0.1),
                child: Icon(material.category.icon, color: DesignSystem.electricBlue, size: 18),
              ),
              title: Text(material.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${material.category.displayName} • ${material.subType}'),
              trailing: Text('${material.currentStock} ${material.unitType.label}'),
              onTap: () {
                close(context, material);
              },
            );
          },
        );
      },
    );
  }
  
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: DesignSystem.charcoalBlack),
        titleTextStyle: TextStyle(
          color: DesignSystem.charcoalBlack,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: DesignSystem.textSecondary),
      ),
    );
  }
}


