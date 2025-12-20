import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:provider/provider.dart';
import '../../../../const/color.dart';
import '../../../../provider/locale_provider.dart';
import '../../../../utils/language/app_strings.dart';
import '../../../super_admin_code/superadminprovider/live_stream_provider.dart';

class LiveMadinahTvScreen extends StatefulWidget {
  const LiveMadinahTvScreen({super.key});

  @override
  State<LiveMadinahTvScreen> createState() => _LiveMadinahTvScreenState();
}

class _LiveMadinahTvScreenState extends State<LiveMadinahTvScreen> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  late HijriCalendar _hijriDate;
  late Map<String, String> _prayerTimes;
  late LiveStreamProvider _streamProvider;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();

    _streamProvider = Provider.of<LiveStreamProvider>(context, listen: false);

    // Listen to provider changes
    _streamProvider.addListener(_onProviderUpdate);

    _hijriDate = HijriCalendar.now();
    _prayerTimes = _getSaudiPrayerTimes();

    // Initialize player if provider already has data
    if (!_streamProvider.isLoading && _streamProvider.errorMessage.isEmpty) {
      _initializePlayer();
    }
  }

  void _onProviderUpdate() {
    if (!_streamProvider.isLoading && _streamProvider.errorMessage.isEmpty) {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    try {
      final videoUrl = _streamProvider.madinahUrl;
      final videoId = _extractVideoId(videoUrl);

      if (videoId.isEmpty) {
        throw Exception('Invalid video ID extracted from URL');
      }

      print('Initializing player with video ID: $videoId');

      _controller?.dispose();

      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
          loop: false,
          isLive: true,
          forceHD: true, // Add this for better quality
        ),
      )..addListener(listener);

      if (mounted) {
        setState(() {
          _isPlayerReady = false;
        });
      }
    } catch (e) {
      print('Error initializing player: $e');
      if (mounted) {
        setState(() {
          _isPlayerReady = false;
        });
      }
    }
  }

  String _extractVideoId(String url) {
    try {
      // Extract video ID using the same logic as in provider
      if (url.contains('youtube.com/live/')) {
        final uri = Uri.parse(url);
        final segments = uri.pathSegments;
        if (segments.isNotEmpty && segments.contains('live')) {
          final liveIndex = segments.indexOf('live');
          if (segments.length > liveIndex + 1) {
            String videoId = segments[liveIndex + 1];
            if (videoId.contains('?')) {
              videoId = videoId.split('?').first;
            }
            return videoId;
          }
        }
      }
      // Fallback to YouTubePlayer converter
      return YoutubePlayer.convertUrlToId(url) ?? '';
    } catch (e) {
      return '';
    }
  }


  void listener() {
    if (_isPlayerReady && mounted && !_controller!.value.isFullScreen) {
      setState(() {});
    }
  }

  Map<String, String> _getSaudiPrayerTimes() {
    final now = DateTime.now();
    final madinah = tz.getLocation('Asia/Riyadh');
    final currentDate = tz.TZDateTime.from(now, madinah);

    return {
      'Fajr': '5:00 AM',
      'Dhuhr': '12:30 PM',
      'Asr': '3:45 PM',
      'Maghrib': currentDate.month >= 9 && currentDate.month <= 3 ? '6:00 PM' : '6:30 PM',
      'Isha': '8:00 PM',
    };
  }

  @override
  void dispose() {
    _streamProvider.removeListener(_onProviderUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    final streamProvider = Provider.of<LiveStreamProvider>(context);

    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    if (streamProvider.isLoading || _controller == null) {
      return Scaffold(
        backgroundColor: AppColors.mainColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                AppStrings.getString('loadingStream', currentLocale),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (streamProvider.errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: AppColors.mainColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text(
                  AppStrings.getString('errorLoadingStream', currentLocale),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  streamProvider.errorMessage,
                  style: GoogleFonts.poppins(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => streamProvider.loadStreamUrls(context),
                  child: Text(AppStrings.getString('retry', currentLocale),style: GoogleFonts.poppins(

                  ),),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(currentLocale),

            Expanded(
              child: Center(
                child: YoutubePlayerBuilder(
                  player: YoutubePlayer(
                    controller: _controller!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: AppColors.mainColor,
                    progressColors: ProgressBarColors(
                      playedColor: AppColors.mainColor,
                      handleColor: AppColors.mainColor.withOpacity(0.7),
                    ),
                    onReady: () {
                      _isPlayerReady = true;
                    },
                    bottomActions: [
                      CurrentPosition(),
                      ProgressBar(isExpanded: true),
                      RemainingDuration(),
                      FullScreenButton(),
                    ],
                  ),
                  builder: (context, player) {
                    return Column(
                      children: [
                        _buildPrayerTimesBar(currentLocale),
                        const SizedBox(height: 8),
                        Expanded(child: player),
                      ],
                    );
                  },
                ),
              ),
            ),

            _buildControlsAndInfo(currentLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String currentLocale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mainColor,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.back),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Icon(Icons.mosque, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            AppStrings.getString('liveMadinahTv', currentLocale),

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _streamProvider.loadStreamUrls(context).then((_) {
                _initializePlayer();
                setState(() {});
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: (){
              _showAboutDialog(currentLocale);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesBar(String currentLocale) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.mainColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _prayerTimeItem(AppStrings.getString('fajr', currentLocale), _prayerTimes['Fajr']!),
          _prayerTimeDivider(),
          _prayerTimeItem(AppStrings.getString('dhuhr', currentLocale), _prayerTimes['Dhuhr']!),
          _prayerTimeDivider(),
          _prayerTimeItem(AppStrings.getString('asr', currentLocale), _prayerTimes['Asr']!),
          _prayerTimeDivider(),
          _prayerTimeItem(AppStrings.getString('maghrib', currentLocale), _prayerTimes['Maghrib']!),
          _prayerTimeDivider(),
          _prayerTimeItem(AppStrings.getString('isha', currentLocale), _prayerTimes['Isha']!),
        ],
      ),
    );
  }

  Widget _prayerTimeItem(String name, String time) {
    return Column(
      children: [
        Text(
          name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _prayerTimeDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildControlsAndInfo(String currentLocale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mainColor.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _controlButton(Icons.volume_up, () => _controller!.unMute()),
              _controlButton(Icons.volume_off, () => _controller!.mute()),
              _controlButton(Icons.share, (){
                _shareStream(currentLocale);
              }),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_getCurrentDate()} | ${_getHijriDate()}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Text(
            AppStrings.getString('liveFromProphetsMosque', currentLocale),

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.getString('watchFromMasjidAlHaram', currentLocale),

            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      iconSize: 28,
      onPressed: onPressed,
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  String _getHijriDate() {
    return '${_hijriDate.hDay} ${_hijriDate.longMonthName} ${_hijriDate.hYear} AH';
  }

  void _shareStream(String currentLocale) async {
    final url = _streamProvider.madinahUrl;
    await Share.share(

      '${AppStrings.getString('watchFromMasjidAlHaram', currentLocale)}, : $url',
      subject: 'Live Madina TV Stream',
    );
  }

  void _showAboutDialog(String currentLocale) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.whiteBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.getString('aboutLiveMadinahTv', currentLocale),

                  style: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                Text(

                  '${AppStrings.getString('aboutDescription', currentLocale)} \n\n'
                      '${AppStrings.getString('features', currentLocale)}:\n'
                      '${AppStrings.getString('featureList', currentLocale)}',
                  style: GoogleFonts.poppins(
                    color: AppColors.blackColor.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppStrings.getString('close', currentLocale),
                    style: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}