class SpecialNamaz {
  final String namaz1Name;
  final String namaz1Time;
  final String namaz2Name;
  final String namaz2Time;
  final String namaz3Name;
  final String namaz3Time;
  final String imamId;

  SpecialNamaz({
    required this.namaz1Name,
    required this.namaz1Time,
    required this.namaz2Name,
    required this.namaz2Time,
    required this.namaz3Name,
    required this.namaz3Time,
    required this.imamId
  });

  factory SpecialNamaz.fromMap(Map<String, dynamic> map) {
    return SpecialNamaz(
      namaz1Name: map['namaz1Name'] ?? '',
      namaz1Time: map['namaz1Time'] ?? '',
      namaz2Name: map['namaz2Name'] ?? '',
      namaz2Time: map['namaz2Time'] ?? '',
      namaz3Name: map['namaz3Name'] ?? '',
      namaz3Time: map['namaz3Time'] ?? '',
      imamId: map['imamId'] ?? '',
    );
  }
}
