import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/modules/inventory/materials/models/material_model.dart';
import 'package:construction_app/modules/inventory/materials/screens/material_detail_screen.dart';
import 'package:construction_app/services/mock_inventory_service.dart';
import 'package:construction_app/shared/theme/design_system.dart';

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
    final inventoryService = this.context.read<MockInventoryService>();
    
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
                backgroundColor: DesignSystem.electricBlue.withOpacity(0.1),
                child: Icon(material.category.icon, color: DesignSystem.electricBlue, size: 18),
              ),
              title: Text(material.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${material.category.displayName} • ${material.subType}'),
              trailing: Text('${material.currentStock} ${material.unitType.label}'),
              onTap: () {
                close(context, material);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MaterialDetailScreen(materialId: material.id)),
                );
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
    final isDark = theme.brightness == Brightness.dark;
    
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400]),
      ),
    );
  }
}
