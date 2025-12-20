import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';

import '../../../../provider/locale_provider.dart';
import '../../../../utils/model/quran_surah_list_model.dart';
import '../surah_ayah_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  late Future<QuranSurahListModel> futureSurahs;

  @override
  void initState() {
    super.initState();
    futureSurahs = fetchSurahs();
  }

  Future<QuranSurahListModel> fetchSurahs() async {

    final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/quran/ar.alafasy'));

    if (response.statusCode == 200) {
      return QuranSurahListModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load surahs');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 80),
                  Text(
                    AppStrings.getString('surahList', currentLocale),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<QuranSurahListModel>(
                future: futureSurahs,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: snapshot.data!.data.surahs.length,
                      itemBuilder: (context, index) {
                        final surah = snapshot.data!.data.surahs[index];
                        return _buildSurahCard(context, surah,currentLocale);
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          AppStrings.getString('failSurahLoad', currentLocale),
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    );
                  }
                  return _buildShimmerLoading();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahCard(BuildContext context, Surah surah,final currentLocal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AyahScreen(surah: surah),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.mainColor.withOpacity(0.17),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${surah.number}',
                  style: GoogleFonts.poppins(
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.englishName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      surah.englishNameTranslation,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    surah.name,
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      color: AppColors.mainColor,
                    ),
                  ),
                  Text(
                    '${surah.ayahs.length} ${AppStrings.getString('verses', currentLocal)}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}