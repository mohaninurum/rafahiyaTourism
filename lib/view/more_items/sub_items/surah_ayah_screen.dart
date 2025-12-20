import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:shimmer/shimmer.dart';
import '../../../provider/locale_provider.dart';
import '../../../utils/model/quran_surah_list_model.dart';

class AyahScreen extends StatefulWidget {
  final Surah surah;

  const AyahScreen({super.key, required this.surah});

  @override
  State<AyahScreen> createState() => _AyahScreenState();
}

class _AyahScreenState extends State<AyahScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  int? currentlyPlayingAyah;
  int? currentAyahIndex;
  bool isPlayingFullSurah = false;

  @override
  void initState() {
    super.initState();
    audioPlayer.onPlayerComplete.listen((event) {
      if (isPlayingFullSurah) {
        playNextAyah();
      } else {
        setState(() => currentlyPlayingAyah = null);
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playAyah(String audioUrl) async {
    try {
      await audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  void playFullSurah(int startIndex) async {
    setState(() {
      isPlayingFullSurah = true;
      currentAyahIndex = startIndex;
      currentlyPlayingAyah = widget.surah.ayahs[startIndex].numberInSurah;
    });
    await playAyah(widget.surah.ayahs[startIndex].audio);
  }

  void playNextAyah() async {
    if (currentAyahIndex == null) return;
    int nextIndex = currentAyahIndex! + 1;
    if (nextIndex < widget.surah.ayahs.length) {
      setState(() {
        currentAyahIndex = nextIndex;
        currentlyPlayingAyah = widget.surah.ayahs[nextIndex].numberInSurah;
      });
      await playAyah(widget.surah.ayahs[nextIndex].audio);
    } else {
      setState(() {
        isPlayingFullSurah = false;
        currentlyPlayingAyah = null;
        currentAyahIndex = null;
      });
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
                    icon: const Icon(CupertinoIcons.back, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.surah.englishName,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSurahHeader(currentLocale),
                    const SizedBox(height: 24),
                    _buildAyahsList(currentLocale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahHeader(final currentLocal) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.surah.name,
              style: GoogleFonts.amiri(fontSize: 32, color: AppColors.mainColor),
            ),
            const SizedBox(height: 8),
            Text(
              widget.surah.englishName,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.surah.englishNameTranslation,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  backgroundColor: AppColors.mainColor.withOpacity(0.1),
                  label: Text('${AppStrings.getString('verses', currentLocal)}: ${widget.surah.ayahs.length}', style: GoogleFonts.poppins(color: AppColors.mainColor)),
                ),
                const SizedBox(width: 8),
                Chip(
                  backgroundColor: AppColors.mainColor.withOpacity(0.1),
                  label: Text(
                    widget.surah.revelationType == 'Meccan' ? 'Meccan' : 'Medinan',
                    style: GoogleFonts.poppins(color: AppColors.mainColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahsList(final currentLocal) {
    if (widget.surah.ayahs.isEmpty) {
      return _buildShimmerAyahs();
    }

    return Column(
      children: widget.surah.ayahs.asMap().entries.map((entry) {
        final index = entry.key;
        final ayah = entry.value;
        final isPlaying = currentlyPlayingAyah == ayah.numberInSurah;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.mainColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${ayah.numberInSurah}',
                        style: GoogleFonts.poppins(
                          color: AppColors.mainColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                        color: AppColors.mainColor,
                        size: 28,
                      ),
                      onPressed: () async {
                        if (isPlaying && isPlayingFullSurah) {
                          await audioPlayer.pause();
                          setState(() => isPlayingFullSurah = false);
                        } else {
                          await audioPlayer.stop();
                          playFullSurah(index);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  ayah.text,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(fontSize: 24),
                ),
                const SizedBox(height: 16),
                Divider(color: AppColors.mainColor.withOpacity(0.2)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppStrings.getString('juz', currentLocal)} ${ayah.juz}',
                      style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    Text(
                      '${AppStrings.getString('page', currentLocal)} ${ayah.page}',
                      style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShimmerAyahs() {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                        Container(width: 28, height: 28, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(height: 80, color: Colors.white),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[200]),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 60, height: 12, color: Colors.white),
                        Container(width: 60, height: 12, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
