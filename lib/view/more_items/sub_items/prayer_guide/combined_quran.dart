import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import '../../../../const/color.dart';
import '../../../../provider/locale_provider.dart';

class QuranAyah {
  final int number;
  final int numberInSurah;
  final String text;
  final String audio;

  QuranAyah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    required this.audio,
  });

  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    return QuranAyah(
      number: json['number'],
      numberInSurah: json['numberInSurah'],
      text: json['text'],
      audio: json['audio'],
    );
  }
}

class CombinedQuranScreen extends StatefulWidget {
  const CombinedQuranScreen({super.key});

  @override
  State<CombinedQuranScreen> createState() => _CombinedQuranScreenState();
}

class _CombinedQuranScreenState extends State<CombinedQuranScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<QuranAyah> _allAyahs = [];
  int _currentAyahIndex = 0;
  bool _isPlaying = false;
  bool _isCompleted = false;
  final Set<int> _completedAyahs = {};
  Duration _ayahDuration = Duration.zero;
  Duration _remainingTime = Duration.zero;
  bool _isLoading = true;
  String? _errorMessage;
  double _playbackRate = 1.0;
  bool _showSpeedOptions = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _loadSavedProgress().then((_) => _loadAllAyahs());
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _saveProgress();
    super.dispose();
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentAyahIndex = prefs.getInt('lastAyahIndex') ?? 0;
      _playbackRate = prefs.getDouble('playbackRate') ?? 1.0;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastAyahIndex', _currentAyahIndex);
    await prefs.setDouble('playbackRate', _playbackRate);
  }

  void _initAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _ayahDuration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() => _remainingTime = _ayahDuration - position);
    });

    // Add this new listener
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isCompleted = true;
        _isPlaying = false;
      });
    });
  }

  Future<void> _loadAllAyahs() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/quran/ar.alafasy'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final surahs = data['data']['surahs'] as List;

        List<QuranAyah> allAyahs = [];

        for (var surah in surahs) {
          final ayahs = surah['ayahs'] as List;
          for (var ayah in ayahs) {
            allAyahs.add(QuranAyah.fromJson(ayah));
          }
        }

        setState(() {
          _allAyahs = allAyahs;
          _isLoading = false;
        });

        if (_allAyahs.isNotEmpty) {
          _playAyah(_currentAyahIndex);
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load Quran data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _playAyah(int index) async {
    if (index >= _allAyahs.length) {
      setState(() {
        _isCompleted = true;
        _isPlaying = false;
      });
      return;
    }

    setState(() {
      _currentAyahIndex = index;
      _isPlaying = true;
      _isCompleted = false;
    });

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setPlaybackRate(_playbackRate);
      await _audioPlayer.play(UrlSource(_allAyahs[index].audio));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _proceedToNextAyah() {
    if (_currentAyahIndex < _allAyahs.length - 1) {
      setState(() => _completedAyahs.add(_currentAyahIndex));
      _playAyah(_currentAyahIndex + 1);
      _saveProgress();
    } else {
      setState(() {
        _completedAyahs.add(_currentAyahIndex);
        _isCompleted = true;
        _isPlaying = false;
      });
      _saveProgress();
    }
  }

  void _goToPreviousAyah() {
    if (_currentAyahIndex > 0) {
      setState(() => _completedAyahs.remove(_currentAyahIndex));
      _playAyah(_currentAyahIndex - 1);
      _saveProgress();
    }
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_isCompleted || _remainingTime <= Duration.zero) {
        // Reset the completion state and play from beginning
        setState(() {
          _isCompleted = false;
          _isPlaying = true;
        });
        await _audioPlayer.stop();
        await _audioPlayer.setPlaybackRate(_playbackRate);
        await _audioPlayer.play(UrlSource(_allAyahs[_currentAyahIndex].audio));
      } else {
        await _audioPlayer.resume();
      }
    }
  }


  void _resetProgress(String currentLocale) async {
    final confirmed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppStrings.getString('resetProgress', currentLocale),style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),),

            content: Text(AppStrings.getString('restartFromStart', currentLocale),style: GoogleFonts.poppins(

            ),),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppStrings.getString('cancel', currentLocale),style: GoogleFonts.poppins(),),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppStrings.getString('reset', currentLocale)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _currentAyahIndex = 0;
        _completedAyahs.clear();
        _isCompleted = false;
      });
      _playAyah(0);
      _saveProgress();
    }
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackRate = speed;
      _showSpeedOptions = false;
    });
    _audioPlayer.setPlaybackRate(speed);
    _saveProgress();
  }

  Widget _buildShimmerLoading() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Colors.white.withOpacity(0.3),
                        highlightColor: Colors.white.withOpacity(0.5),
                        child: Container(
                          height: 24,
                          width: 200,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              Shimmer.fromColors(
                baseColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.5),
                child: Container(height: 3, color: Colors.white),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          height: 300,
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.white.withOpacity(0.3),
                      highlightColor: Colors.white.withOpacity(0.5),
                      child: Container(
                        height: 16,
                        width: 150,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Shimmer.fromColors(
                      baseColor: Colors.white.withOpacity(0.3),
                      highlightColor: Colors.white.withOpacity(0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Shimmer.fromColors(
                      baseColor: Colors.white.withOpacity(0.3),
                      highlightColor: Colors.white.withOpacity(0.5),
                      child: Container(
                        height: 18,
                        width: 200,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Text(
            _errorMessage!,
            style: GoogleFonts.poppins(color: Colors.red),
          ),
        ),
      );
    }

    if (_allAyahs.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Text(
            AppStrings.getString('noAyah', currentLocale),
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      );
    }

    final currentAyah = _allAyahs[_currentAyahIndex];
    final progressValue = (_currentAyahIndex + 1) / _allAyahs.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        AppStrings.getString('reciteQuran', currentLocale),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.info_outline, color: Colors.white),
                      onPressed: (){
                        _showReadingFlowDialog(currentLocale);
                      },
                    ),
                  ],
                ),
              ),

              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor!),
                minHeight: 3,
              ),

              if (_showSpeedOptions)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: AppColors.mainColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSpeedButton(0.25),
                      _buildSpeedButton(0.5),
                      _buildSpeedButton(0.75),
                      _buildSpeedButton(1.0),
                      _buildSpeedButton(1.25),
                      _buildSpeedButton(1.5),
                      _buildSpeedButton(1.75),
                    ],
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 20,right: 20,bottom: 20,top: 10),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: (){
                            _resetProgress(currentLocale);
                          },
                          icon: Icon(Icons.refresh, color: Colors.white),
                          label: Text(AppStrings.getString('resetProgress', currentLocale),style: GoogleFonts.poppins(
                            color: AppColors.whiteColor,

                          ),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainColor,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'القرآن الكريم',
                                style: GoogleFonts.amiri(
                                  fontSize: 32,
                                  color: AppColors.mainColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppStrings.getString('holyQuran', currentLocale),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.getString('sequenceQuran', currentLocale),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Chip(
                                backgroundColor: AppColors.mainColor!
                                    .withOpacity(0.1),
                                label: Text(
                                  '${AppStrings.getString('currentAyah', currentLocale)}: ${_currentAyahIndex + 1}/${_allAyahs.length}',
                                  style: TextStyle(color: AppColors.mainColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.mainColor!.withOpacity(
                                      0.15,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    currentAyah.numberInSurah.toString(),
                                    style: GoogleFonts.poppins(
                                      color: AppColors.mainColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (_completedAyahs.contains(_currentAyahIndex))
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.mainColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: AppColors.mainColor,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          AppStrings.getString('completed', currentLocale),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.mainColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            Text(
                              currentAyah.text,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.amiri(
                                fontSize: 28,
                                height: 1.8,
                              ),
                            ),

                            const SizedBox(height: 24),

                            Column(
                              children: [
                                LinearProgressIndicator(
                                  value:
                                      _ayahDuration.inSeconds > 0
                                          ? (_ayahDuration - _remainingTime)
                                                  .inSeconds /
                                              _ayahDuration.inSeconds
                                          : 0,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.mainColor!,
                                  ),
                                  minHeight: 4,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(_ayahDuration - _remainingTime).inSeconds}s / ${_ayahDuration.inSeconds}s',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${AppStrings.getString('ayah', currentLocale)} ${_currentAyahIndex + 1} of ${_allAyahs.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            size: 32,
                            color:
                                _currentAyahIndex > 0
                                    ? Colors.white
                                    : Colors.grey[400],
                          ),
                          onPressed:
                              _currentAyahIndex > 0 ? _goToPreviousAyah : null,
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.pause_rounded,
                            size: 36,
                            color: _isPlaying ? Colors.white : Colors.grey[400],
                          ),
                          onPressed: _isPlaying ? _togglePlayPause : null,
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.play_arrow_rounded,
                            size: 36,
                            color:
                                !_isPlaying ? Colors.white : Colors.grey[400],
                          ),
                          onPressed: !_isPlaying ? _togglePlayPause : null,
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.skip_next_rounded,
                            size: 32,
                            color:
                                _currentAyahIndex < _allAyahs.length - 1
                                    ? Colors.white
                                    : Colors.grey[400],
                          ),
                          onPressed:
                              _currentAyahIndex < _allAyahs.length - 1
                                  ? _proceedToNextAyah
                                  : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: Colors.white,size: 30,),
                          onPressed: () {
                            if (_playbackRate > 0.25) _changePlaybackSpeed((_playbackRate - 0.25).clamp(0.25, 1.75));
                          },
                        ),
                        Text(
                          '${AppStrings.getString('speed', currentLocale)}: ${_playbackRate.toStringAsFixed(2)}x',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500,fontSize: 16),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: Colors.white,size: 30,),
                          onPressed: () {
                            if (_playbackRate < 1.75) _changePlaybackSpeed((_playbackRate + 0.25).clamp(0.25, 1.75));
                          },
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedButton(double speed) {
    return GestureDetector(
      onTap: () => _changePlaybackSpeed(speed),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _playbackRate == speed ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${speed}x',
          style: TextStyle(
            color: _playbackRate == speed ? AppColors.mainColor! : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showReadingFlowDialog(String currentLocale) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              AppStrings.getString('readGuide', currentLocale),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.mainColor,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFlowStep(
                  '1. ${AppStrings.getString('playBack', currentLocale)}',
                       AppStrings.getString('playPause', currentLocale),
                ),
                const SizedBox(height: 12),
                _buildFlowStep(
                  '2. ${AppStrings.getString('progressSave', currentLocale)}',
                  AppStrings.getString('saveAuto', currentLocale),
                ),
                const SizedBox(height: 12),
                _buildFlowStep(
                  '3. ${AppStrings.getString('playSpeed', currentLocale)}',
                  AppStrings.getString('adjustSpeed', currentLocale),
                ),
                const SizedBox(height: 12),
                _buildFlowStep(
                  '4. ${AppStrings.getString('completion', currentLocale)}',
                  AppStrings.getString('greenCheckMark', currentLocale),
                ),
                const SizedBox(height: 12),
                _buildFlowStep(
                  '5. ${AppStrings.getString('reset', currentLocale)}',
                  AppStrings.getString('startFromBeginning', currentLocale),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppStrings.getString('gotIt', currentLocale),
                  style: GoogleFonts.poppins(
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );
  }

  Widget _buildFlowStep(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
