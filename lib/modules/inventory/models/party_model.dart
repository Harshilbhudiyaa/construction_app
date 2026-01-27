enum PartyCategory {
  supplier,
  contractor,
  siteStaff,
  other
}

extension PartyCategoryExtension on PartyCategory {
  String get displayName {
    switch (this) {
      case PartyCategory.supplier: return 'Supplier';
      case PartyCategory.contractor: return 'Contractor';
      case PartyCategory.siteStaff: return 'Site Staff';
      case PartyCategory.other: return 'Other';
    }
  }
}

class PartyModel {
  final String id;
  final String name;
  final PartyCategory category;
  final String? contactNumber;
  final String? gstNumber;
  final String? address;
  final DateTime createdAt;

  PartyModel({
    required this.id,
    required this.name,
    required this.category,
    this.contactNumber,
    this.gstNumber,
    this.address,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'contactNumber': contactNumber,
      'gstNumber': gstNumber,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'],
      name: json['name'],
      category: PartyCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => PartyCategory.other,
      ),
      contactNumber: json['contactNumber'],
      gstNumber: json['gstNumber'],
      address: json['address'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  PartyModel copyWith({
    String? name,
    PartyCategory? category,
    String? contactNumber,
    String? gstNumber,
    String? address,
  }) {
    return PartyModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      contactNumber: contactNumber ?? this.contactNumber,
      gstNumber: gstNumber ?? this.gstNumber,
      address: address ?? this.address,
      createdAt: createdAt,
    );
  }
}
