class RamadanDua {
  final String category;
  final String? subcategory;
  final List<DuaItem> duas;

  RamadanDua({
    required this.category,
    this.subcategory,
    required this.duas,
  });

  factory RamadanDua.fromJson(Map<String, dynamic> json) {
    return RamadanDua(
      category: json['category'],
      subcategory: json['subcategory'],
      duas: (json['duas'] as List).map((i) => DuaItem.fromJson(i)).toList(),
    );
  }
}

class DuaItem {
  final int id;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;

  DuaItem({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
  });

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    return DuaItem(
      id: json['id'],
      title: json['title'],
      arabic: json['arabic'],
      transliteration: json['transliteration'],
      translation: json['translation'],
      reference: json['reference'],
    );
  }
}