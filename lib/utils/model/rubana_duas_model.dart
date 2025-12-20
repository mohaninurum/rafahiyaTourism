class RabbanaDua {
  final int id;
  final String surah;
  final String verse;
  final String arabic;
  final String transliteration;
  final String translation;

  RabbanaDua({
    required this.id,
    required this.surah,
    required this.verse,
    required this.arabic,
    required this.transliteration,
    required this.translation,
  });

  factory RabbanaDua.fromJson(Map<String, dynamic> json) {
    return RabbanaDua(
      id: json['id'] ?? 0,
      surah: json['surah'] ?? '',
      verse: json['verse'] ?? '',
      arabic: json['arabic'] ?? '',
      transliteration: json['transliteration'] ?? '',
      translation: json['translation'] ?? '',
    );
  }
}