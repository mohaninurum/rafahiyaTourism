import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../../../const/color.dart';
import '../../../super_admin_code/models/tutorial_videos_model.dart';
import '../../../super_admin_code/superadminprovider/tutorial_videos_provider/tutorial_videos_provider.dart';
import '../../../../provider/locale_provider.dart';
import '../../../../utils/language/app_strings.dart';

class TutorialVideosScreen extends StatefulWidget {
  const TutorialVideosScreen({super.key});

  @override
  State<TutorialVideosScreen> createState() => _TutorialVideosScreenState();
}

class _TutorialVideosScreenState extends State<TutorialVideosScreen> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    // Load videos when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TutorialVideoProvider>(context, listen: false).loadTutorialVideos();
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _changeVideo(int index, List<TutorialVideo> videos) {
    if (index == _currentIndex) return;

    // Dispose of previous controllers
    _chewieController?.dispose();
    _videoPlayerController?.dispose();

    setState(() {
      _currentIndex = index;
    });

    // Initialize new video controller
    _initializeVideoController(videos[index].videoUrl);

    _scrollController.animateTo(
      (index * 100).toDouble(),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _initializeVideoController(String videoUrl) {
    _videoPlayerController = VideoPlayerController.network(videoUrl);

    _videoPlayerController!.initialize().then((_) {
      // Video initialized successfully
      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: false,
            looping: false,
            showControls: true,
            allowFullScreen: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: AppColors.mainColor,
              handleColor: AppColors.mainColor,
              backgroundColor: Colors.grey.shade300,
              bufferedColor: Colors.grey.shade400,
            ),
          );
        });
      }
    }).catchError((error) {
      // Handle initialization error
      print('Video initialization error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getString('failedToLoadVideo', _getCurrentLocale())),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  String _getCurrentLocale() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Consumer<TutorialVideoProvider>(
      builder: (context, tutorialProvider, child) {
        final videos = tutorialProvider.videos;

        if (tutorialProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor),
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppStrings.getString('loadingVideo', currentLocale),
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (videos.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Text(
                AppStrings.getString('islamicTutorials', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.getString('noTutorialVideos', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.getString('checkBackLater', currentLocale),
                    style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Initialize the first video if not already done
        if (_chewieController == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeVideoController(videos[_currentIndex].videoUrl);
          });
        }

        final currentVideo = videos[_currentIndex];

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              AppStrings.getString('islamicTutorials', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          body: Column(
            children: [
              // Main Video Player
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _chewieController != null &&
                      _chewieController!.videoPlayerController.value.isInitialized
                      ? Chewie(controller: _chewieController!)
                      : Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.getString('loadingVideo', currentLocale),
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Video Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentVideo.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentVideo.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${AppStrings.getString('uploaded', currentLocale)}: ${_formatDate(currentVideo.createdAt)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Video List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.getString('moreIslamicVideos', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1}/${videos.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Video List (using thumbnails)
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];

                    return GestureDetector(
                      onTap: () => _changeVideo(index, videos),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.mainColor.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _currentIndex == index
                                ? AppColors.mainColor
                                : Colors.grey.shade200,
                            width: _currentIndex == index ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Thumbnail
                            Container(
                              width: 120,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(12)),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    _getVideoThumbnailUrl(video.videoUrl),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.play_circle_filled,
                                  size: 40,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),

                            // Video Info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${AppStrings.getString('uploaded', currentLocale)}: ${_formatDate(video.createdAt)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getVideoThumbnailUrl(String videoUrl) {
    if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
      final videoId = videoUrl.contains('youtube.com')
          ? videoUrl.split('v=')[1].split('&')[0]
          : videoUrl.split('/').last;
      return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
    }

    return 'https://placehold.co/600x400/${AppColors.mainColor.value.toRadixString(16).substring(2)}/white?text=${Uri.encodeComponent(AppStrings.getString('videoThumbnailPlaceholder', _getCurrentLocale()))}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}