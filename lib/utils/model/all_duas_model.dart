class AllDuas {
  final List<DuaCategory> categories;

  AllDuas({required this.categories});

  factory AllDuas.fromJson(Map<String, dynamic> json) {
    return AllDuas(
      categories: (json['all_duas'] as List)
          .map((category) => DuaCategory.fromJson(category))
          .toList(),
    );
  }
}

class DuaCategory {
  final String category;
  final String? subcategory;
  final List<DuaItem> duas;

  DuaCategory({
    required this.category,
    this.subcategory,
    required this.duas,
  });

  factory DuaCategory.fromJson(Map<String, dynamic> json) {
    return DuaCategory(
      category: json['category'],
      subcategory: json['subcategory'],
      duas: (json['duas'] as List).map((dua) => DuaItem.fromJson(dua)).toList(),
    );
  }

  String get fullTitle => subcategory != null
      ? '$category - $subcategory'
      : category;
}

class DuaItem {
  final int id;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String? reference;  // Make this nullable

  DuaItem({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    this.reference,  // No required keyword
  });

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    return DuaItem(
      id: json['id'] ?? 0,  // Provide default value
      title: json['title'] ?? '',  // Provide default value
      arabic: json['arabic'] ?? '',  // Provide default value
      transliteration: json['transliteration'] ?? '',  // Provide default value
      translation: json['translation'] ?? '',  // Provide default value
      reference: json['reference'],  // Can be null
    );
  }
}