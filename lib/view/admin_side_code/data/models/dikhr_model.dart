
class Dikhr {
  final String name;
  final String arabic;
  final bool isCustom;

  Dikhr({
    required this.name,
    required this.arabic,
    this.isCustom = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Dikhr &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              arabic == other.arabic;

  @override
  int get hashCode => name.hashCode ^ arabic.hashCode;
}

final List<Dikhr> defaultDikhrs = [
  Dikhr(name: "Subhan Allah", arabic: "سُبْحَانَ اللّٰهِ"),
  Dikhr(name: "Alhamdulillah", arabic: "ٱلْحَمْدُ لِلَّٰهِ"),
  Dikhr(name: "Allahu Akbar", arabic: "ٱللَّٰهُ أَكْبَرُ"),
  Dikhr(name: "Astaghfirullah", arabic: "أَسْتَغْفِرُ ٱللَّٰهَ"),
  Dikhr(name: "La ilaha illallah", arabic: "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ"),
  Dikhr(name: "Darood Shareef", arabic: "ٱللَّٰهُمَّ صَلِّ عَلَى مُحَمَّدٍ"),
  Dikhr(
      name: "Ayat Karima",
      arabic: "لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ ٱلظَّالِمِينَ"
  ),
];