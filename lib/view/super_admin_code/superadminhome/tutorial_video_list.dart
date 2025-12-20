import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/upload_tutorial.dart';
import 'package:video_player/video_player.dart';
import '../../../const/color.dart';
import '../models/tutorial_videos_model.dart';
import '../superadminprovider/tutorial_videos_provider/tutorial_videos_provider.dart';

class TutorialVideosListScreen extends StatefulWidget {
  const TutorialVideosListScreen({super.key});

  @override
  State<TutorialVideosListScreen> createState() => _TutorialVideosListScreenState();
}

class _TutorialVideosListScreenState extends State<TutorialVideosListScreen> {
  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    // Load videos when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TutorialVideoProvider>(context, listen: false).loadTutorialVideos();
    });
  }

  void _navigateToVideoScreen({TutorialVideo? video}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorialVideoScreen(existingVideo: video),
      ),
    );
  }

  void _showDeleteDialog(TutorialVideo video, String currentLocale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppStrings.getString('deleteVideo', currentLocale),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '${AppStrings.getString('deleteVideoConfirmation', currentLocale)} "${video.title}"?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await Provider.of<TutorialVideoProvider>(context, listen: false)
                      .deleteTutorialVideo(video.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppStrings.getString('videoDeletedSuccess', currentLocale),
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      backgroundColor: AppColors.mainColor,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${AppStrings.getString('failedToDeleteVideo', currentLocale)}: $e',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                AppStrings.getString('delete', currentLocale),
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          AppStrings.getString('tutorialVideos', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _navigateToVideoScreen(),
            icon: const Icon(Icons.add, size: 28),
            tooltip: AppStrings.getString('addNewVideo', currentLocale),
          ),
        ],
      ),
      body: Consumer<TutorialVideoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor),
              ),
            );
          }

          if (provider.videos.isEmpty) {
            return Center(
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
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.getString('tapToAddFirstVideo', currentLocale),
                    style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _navigateToVideoScreen(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      AppStrings.getString('addVideo', currentLocale),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadTutorialVideos(),
            color: AppColors.mainColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.videos.length,
              itemBuilder: (context, index) {
                final video = provider.videos[index];
                return _buildVideoCard(video, currentLocale);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(TutorialVideo video, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _navigateToVideoScreen(video: video),
              backgroundColor: AppColors.mainColor,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: AppStrings.getString('edit', currentLocale),
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (context) => _showDeleteDialog(video, currentLocale),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: AppStrings.getString('delete', currentLocale),
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Card(
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showVideoPreviewDialog(video, currentLocale),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Video thumbnail with play button
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(
                          _getVideoThumbnailUrl(video.videoUrl),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          video.description,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${AppStrings.getString('uploaded', currentLocale)}: ${_formatDate(video.createdAt)}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showVideoPreviewDialog(TutorialVideo video, String currentLocale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  video.description,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FutureBuilder(
                    future: _initializeVideoPlayer(video.videoUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Chewie(
                          controller: ChewieController(
                            videoPlayerController: snapshot.data as VideoPlayerController,
                            autoPlay: true,
                            looping: false,
                            showControls: true,
                          ),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        AppStrings.getString('close', currentLocale),
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _navigateToVideoScreen(video: video);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppStrings.getString('editVideo', currentLocale),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
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

  Future<VideoPlayerController> _initializeVideoPlayer(String videoUrl) async {
    final controller = VideoPlayerController.network(videoUrl);
    await controller.initialize();
    return controller;
  }

  String _getVideoThumbnailUrl(String videoUrl) {

    if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
      final videoId = videoUrl.contains('youtube.com')
          ? videoUrl.split('v=')[1].split('&')[0]
          : videoUrl.split('/').last;
      return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
    }

    return 'https://placehold.co/600x400/${AppColors.mainColor.value.toRadixString(16).substring(2)}/white?text=Video+Thumbnail';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}