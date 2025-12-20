import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, rootBundle;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

class DuaListScreen extends StatefulWidget {
  const DuaListScreen({super.key});

  @override
  State<DuaListScreen> createState() => _DuaListScreenState();
}

class _DuaListScreenState extends State<DuaListScreen> {
  late Future<CombinedDuas> _duasFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _duasFuture = _loadAllDuas();
  }

  Future<CombinedDuas> _loadAllDuas() async {
    try {
      debugPrint('Loading duas from assets...');

      final rabbanaString = await rootBundle.loadString('assets/duas/rubana_dua.json');
      final ramadanString = await rootBundle.loadString('assets/duas/ramadan_dua.json');
      final allDuasString = await rootBundle.loadString('assets/duas/all_duas.json');

      debugPrint('JSON loaded successfully, parsing...');

      final rabbanaJson = json.decode(rabbanaString);
      final ramadanJson = json.decode(ramadanString);
      final allDuasJson = json.decode(allDuasString);

      final combinedDuas = CombinedDuas.fromJson({
        'rabbana_duas': rabbanaJson['rabbana_duas'],
        'ramadan_duas': ramadanJson['ramadan_duas'],
        'all_duas': allDuasJson['all_duas'],
      });

      debugPrint('Duas loaded successfully: '
          '${combinedDuas.allDuas.length} all categories, '
          '${combinedDuas.rabbana.length} rabbana categories, '
          '${combinedDuas.ramadan.length} ramadan categories');

      return combinedDuas;
    } catch (e, stackTrace) {
      debugPrint('Error loading duas: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to load duas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          AppStrings.getString('dailyDuas', currentLocale),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(CupertinoIcons.back, color: Colors.white)
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DuaSearchDelegate(_duasFuture, currentLocale),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryTabs(currentLocale),
          Expanded(
            child: FutureBuilder<CombinedDuas>(
              future: _duasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        '${AppStrings.getString('error', currentLocale)}: ${snapshot.error}'
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return Center(
                    child: Text(AppStrings.getString('noDuasFound', currentLocale)),
                  );
                }

                final data = snapshot.data!;
                final categories = _selectedTab == 0
                    ? data.allDuas
                    : _selectedTab == 1
                    ? data.rabbana
                    : data.ramadan;

                final filteredCategories = _filterCategories(categories);

                if (filteredCategories.isEmpty) {
                  return Center(
                    child: Text(AppStrings.getString('noMatchSearch', currentLocale)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, categoryIndex) {
                    final category = filteredCategories[categoryIndex];
                    return _buildCategorySection(category, context, currentLocale);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(String currentLocale) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton(0, AppStrings.getString('allDuas', currentLocale), currentLocale),
          _buildTabButton(1, AppStrings.getString('rabbana', currentLocale), currentLocale),
          _buildTabButton(2, AppStrings.getString('ramadan', currentLocale), currentLocale),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title, String currentLocale) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _searchQuery = '';
          _searchController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedTab == index ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: _selectedTab == index ? AppColors.mainColor : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<DuaCategory> _filterCategories(List<DuaCategory> categories) {
    if (_searchQuery.isEmpty) return categories;

    return categories.map((category) {
      final filteredDuas = category.duas.where((dua) {
        final title = dua.getTitle('en').toLowerCase();
        final translation = dua.getTranslation('en').toLowerCase();
        final transliteration = dua.getTransliteration('en').toLowerCase();
        final reference = dua.reference?.toLowerCase() ?? '';

        return dua.arabic.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            translation.contains(_searchQuery.toLowerCase()) ||
            transliteration.contains(_searchQuery.toLowerCase()) ||
            title.contains(_searchQuery.toLowerCase()) ||
            reference.contains(_searchQuery.toLowerCase());
      }).toList();

      return DuaCategory(
        category: category.category,
        subcategory: category.subcategory,
        duas: filteredDuas,
      );
    }).where((category) => category.duas.isNotEmpty).toList();
  }


  Widget _buildCategorySection(DuaCategory category, BuildContext context, String currentLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            category.getFullTitle(currentLocale),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.mainColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: category.duas.length,
          itemBuilder: (context, duaIndex) {
            final dua = category.duas[duaIndex];
            return _buildDuaCard(dua, context, currentLocale);
          },
        ),
      ],
    );
  }

  Widget _buildDuaCard(DuaItem dua, BuildContext context, String currentLocale) {
    final translation = dua.getTranslation(currentLocale);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDuaDetails(dua, context, currentLocale),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dua.arabic,
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.bookmark, color: AppColors.mainColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    dua.getTitle(currentLocale), // Use localized title
                    style: GoogleFonts.poppins(
                      color: AppColors.mainColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                translation.length > 60
                    ? '${translation.substring(0, 60)}...'
                    : translation,
                style: GoogleFonts.poppins(
                  color: AppColors.mainColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (dua.reference?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  dua.reference!,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.mainColor,
                  ),
                  onPressed: () => _showDuaDetails(dua, context, currentLocale),
                  child: Text(AppStrings.getString('viewFullDua', currentLocale)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showDuaDetails(DuaItem dua, BuildContext context, String currentLocale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  dua.getTitle(currentLocale), // Use localized title
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dua.arabic,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      height: 1.8,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dua.getTransliteration(currentLocale), // Use localized transliteration
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.mainColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${AppStrings.getString('translation', currentLocale)}:',
                  style: GoogleFonts.poppins(
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dua.getTranslation(currentLocale), // Use localized translation
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                if (dua.reference?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.book, color: AppColors.mainColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dua.reference!,
                            style: GoogleFonts.poppins(
                              color: AppColors.mainColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy, size: 18),
                      label: Text(AppStrings.getString('copy', currentLocale)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(
                              text:
                              '${dua.title}\n\n${dua.arabic}\n\n${dua.transliteration}\n\n${dua.translation}',
                            ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppStrings.getString('duaCopied', currentLocale)),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.share, size: 18),
                      label: Text(AppStrings.getString('share', currentLocale)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onPressed: () {
                        Share.share(
                          '${dua.title}\n\n${dua.arabic}\n\n${dua.transliteration}\n\n${dua.translation}\n\n${dua.reference ?? ''}',
                          subject: '${AppStrings.getString('islamicDua', currentLocale)}: ${dua.title}',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CombinedDuas {
  final List<DuaCategory> rabbana;
  final List<DuaCategory> ramadan;
  final List<DuaCategory> allDuas;

  CombinedDuas({
    required this.rabbana,
    required this.ramadan,
    required this.allDuas,
  });

  factory CombinedDuas.fromJson(Map<String, dynamic> json) {
    return CombinedDuas(
      rabbana: (json['rabbana_duas'] as List)
          .map((category) => DuaCategory.fromJson(category))
          .toList(),
      ramadan: (json['ramadan_duas'] as List)
          .map((category) => DuaCategory.fromJson(category))
          .toList(),
      allDuas: (json['all_duas'] as List)
          .map((category) => DuaCategory.fromJson(category))
          .toList(),
    );
  }
}

class DuaCategory {
  final Map<String, dynamic> category;
  final String? subcategory;
  final List<DuaItem> duas;

  DuaCategory({
    required this.category,
    this.subcategory,
    required this.duas,
  });

  factory DuaCategory.fromJson(Map<String, dynamic> json) {
    return DuaCategory(
      category: _parseCategoryField(json['category']),
      subcategory: DuaItem._parseStringField(json['subcategory']),
      duas: (json['duas'] as List).map((dua) => DuaItem.fromJson(dua)).toList(),
    );
  }

  // Helper method to parse category field
  static Map<String, dynamic> _parseCategoryField(dynamic field) {
    if (field == null) {
      return {'en': ''};
    } else if (field is String) {
      return {'en': field};
    } else if (field is Map<String, dynamic>) {
      return field;
    } else {
      return {'en': field.toString()};
    }
  }

  String getFullTitle(String currentLocale) {
    final categoryText = DuaItem._parseStringField(
        category.containsKey(currentLocale)
            ? category[currentLocale]
            : category['en'] ?? category.values.first
    ) ?? '';

    final subcategoryText = DuaItem._parseStringField(subcategory) ?? '';

    if (subcategoryText.isNotEmpty) {
      return '$categoryText - $subcategoryText';
    }
    return categoryText;
  }
}

class DuaItem {
  final int id;
  final Map<String, dynamic> title;
  final String arabic;
  final Map<String, dynamic> transliteration;
  final Map<String, dynamic> translation;
  final String? reference;
  final String? surah;
  final String? verse;

  DuaItem({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    this.reference,
    this.surah,
    this.verse,
  });

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    return DuaItem(
      id: json['id'] ?? 0,
      title: _parseLocalizedField(json['title']),
      arabic: json['arabic'] ?? '',
      transliteration: _parseLocalizedField(json['transliteration']),
      translation: _parseLocalizedField(json['translation']),
      reference: _parseStringField(json['reference']),
      surah: _parseStringField(json['surah']),
      verse: _parseStringField(json['verse']?.toString()),
    );
  }

  // Helper method to parse localized fields (title, transliteration, translation)
  static Map<String, dynamic> _parseLocalizedField(dynamic field) {
    if (field == null) {
      return {'en': ''};
    } else if (field is String) {
      return {'en': field};
    } else if (field is Map<String, dynamic>) {
      return field;
    } else {
      return {'en': field.toString()};
    }
  }

  // Helper method to parse string fields (reference, surah, verse)
  static String? _parseStringField(dynamic field) {
    if (field == null) {
      return null;
    } else if (field is String) {
      return field.isEmpty ? null : field;
    } else {
      final str = field.toString();
      return str.isEmpty ? null : str;
    }
  }

  String getTitle(String currentLocale) {
    if (title.containsKey(currentLocale)) {
      return title[currentLocale]?.toString() ?? '';
    }
    return title['en']?.toString() ?? title.values.first?.toString() ?? '';
  }

  String getTransliteration(String currentLocale) {
    if (transliteration.containsKey(currentLocale)) {
      return transliteration[currentLocale]?.toString() ?? '';
    }
    return transliteration['en']?.toString() ?? transliteration.values.first?.toString() ?? '';
  }

  String getTranslation(String currentLocale) {
    if (translation.containsKey(currentLocale)) {
      return translation[currentLocale]?.toString() ?? '';
    }
    return translation['en']?.toString() ?? translation.values.first?.toString() ?? '';
  }
}


class DuaSearchDelegate extends SearchDelegate<DuaItem> {
  final Future<CombinedDuas> _duasFuture;
  final String currentLocale;

  DuaSearchDelegate(this._duasFuture, this.currentLocale);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null as DuaItem);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<CombinedDuas>(
      future: _duasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('${AppStrings.getString('error', currentLocale)}: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData) {
          return Center(
            child: Text(AppStrings.getString('noDuasFound', currentLocale)),
          );
        }

        final allDuas = [
          ...snapshot.data!.allDuas.expand((c) => c.duas),
          ...snapshot.data!.rabbana.expand((c) => c.duas),
          ...snapshot.data!.ramadan.expand((c) => c.duas),
        ];

        final results = query.isEmpty
            ? []
            : allDuas.where((dua) {
          final title = dua.getTitle('en').toLowerCase();
          final translation = dua.getTranslation('en').toLowerCase();
          final transliteration = dua.getTransliteration('en').toLowerCase();
          final reference = dua.reference?.toLowerCase() ?? '';

          return dua.arabic.toLowerCase().contains(query.toLowerCase()) ||
              translation.contains(query.toLowerCase()) ||
              transliteration.contains(query.toLowerCase()) ||
              title.contains(query.toLowerCase()) ||
              reference.contains(query.toLowerCase());
        }).toList();

        if (results.isEmpty) {
          return Center(
            child: Text(AppStrings.getString('noMatchSearch', currentLocale)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final dua = results[index];
            final translation = dua.getTranslation(currentLocale);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(dua.getTitle(currentLocale)),
                subtitle: Text(
                  translation.length > 60
                      ? '${translation.substring(0, 60)}...'
                      : translation,
                ),
                onTap: () {
                  close(context, dua);
                  _showDuaDetails(dua, context, currentLocale);
                },
              ),
            );
          },
        );
      },
    );
  }


  void _showDuaDetails(DuaItem dua, BuildContext context, String currentLocale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  dua.getTitle(currentLocale),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dua.arabic,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      height: 1.8,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dua.getTransliteration(currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.mainColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${AppStrings.getString('translation', currentLocale)}:',
                  style: GoogleFonts.poppins(
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dua.getTranslation(currentLocale),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                if (dua.reference?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.book, color: AppColors.mainColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dua.reference!,
                            style: GoogleFonts.poppins(
                              color: AppColors.mainColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy, size: 18),
                      label: Text(AppStrings.getString('copy', currentLocale)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text:
                          '${dua.getTitle(currentLocale)}\n\n${dua.arabic}\n\n${dua.getTransliteration(currentLocale)}\n\n${dua.getTranslation(currentLocale)}',
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppStrings.getString('duaCopied', currentLocale)),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.share, size: 18),
                      label: Text(AppStrings.getString('share', currentLocale)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onPressed: () {
                        Share.share(
                          '${dua.getTitle(currentLocale)}\n\n${dua.arabic}\n\n${dua.getTransliteration(currentLocale)}\n\n${dua.getTranslation(currentLocale)}\n\n${dua.reference ?? ''}',
                          subject: '${AppStrings.getString('islamicDua', currentLocale)}: ${dua.getTitle(currentLocale)}',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



class DuaCollection {
  final List<DuaCategory> categories;

  DuaCollection({required this.categories});

  factory DuaCollection.fromJson(Map<String, dynamic> json) {
    return DuaCollection(
      categories: (json['categories'] as List)
          .map((category) => DuaCategory.fromJson(category))
          .toList(),
    );
  }
}


