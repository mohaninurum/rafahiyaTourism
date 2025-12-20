import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import '../../../const/color.dart';
import '../models/tutorial_videos_model.dart';
import '../superadminprovider/tutorial_videos_provider/tutorial_videos_provider.dart';

class TutorialVideoScreen extends StatefulWidget {
  final TutorialVideo? existingVideo;

  const TutorialVideoScreen({super.key, this.existingVideo});

  @override
  State<TutorialVideoScreen> createState() => _TutorialVideoScreenState();
}

class _TutorialVideoScreenState extends State<TutorialVideoScreen> {
  File? _videoFile;
  VideoPlayerController? _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPlaying = false;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  void _initializeVideoPlayer() {
    _controller?.dispose();

    if (_videoFile != null) {
      _controller = VideoPlayerController.file(_videoFile!)
        ..initialize().then((_) {
          setState(() {});
        });
    } else if (widget.existingVideo != null) {
      // For existing videos from Firebase Storage
      _controller = VideoPlayerController.network(widget.existingVideo!.videoUrl)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void initState() {
    super.initState();

    // If editing an existing video, populate the fields
    if (widget.existingVideo != null) {
      _titleController.text = widget.existingVideo!.title;
      _descriptionController.text = widget.existingVideo!.description;

      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 10),
    );

    if (pickedFile != null) {
      _videoFile = File(pickedFile.path);
      _initializeVideoPlayer();
      setState(() {});
    }
  }

  void _togglePlayPause() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
          _isPlaying = false;
        } else {
          _controller!.play();
          _isPlaying = true;
        }
      });
    }
  }

  Future<void> _uploadVideo() async {
    final currentLocale = _getCurrentLocale(context);

    if (!_formKey.currentState!.validate()) return;
    if (_videoFile == null && widget.existingVideo == null) {
      _showSnackBar(AppStrings.getString('pleaseSelectVideo', currentLocale));
      return;
    }

    try {
      final tutorialProvider = Provider.of<TutorialVideoProvider>(context, listen: false);

      if (widget.existingVideo != null) {
        // Update existing video
        await tutorialProvider.updateTutorialVideo(
          id: widget.existingVideo!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          newVideoFile: _videoFile,
        );
        _showSnackBar(AppStrings.getString('videoUpdatedSuccess', currentLocale));
      } else {
        // Upload new video
        await tutorialProvider.uploadTutorialVideo(
          videoFile: _videoFile!,
          title: _titleController.text,
          description: _descriptionController.text,
        );
        _showSnackBar(AppStrings.getString('videoUploadedSuccess', currentLocale));
      }

      Navigator.of(context).pop();
    } catch (error) {
      _showSnackBar('${AppStrings.getString('error', currentLocale)}: ${error.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: AppColors.mainColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildVideoPreview(String currentLocale) {
    if (_controller != null && _controller!.value.isInitialized) {
      return Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
              if (!_isPlaying)
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          VideoProgressIndicator(
            _controller!,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: AppColors.mainColor,
              bufferedColor: Colors.grey[300]!,
              backgroundColor: Colors.grey[200]!,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.getString('duration', currentLocale)}: ${_controller!.value.duration.toString().substring(0, 7)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (_videoFile != null)
                  Text(
                    '${AppStrings.getString('size', currentLocale)}: ${(_videoFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _togglePlayPause,
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            label: Text(_isPlaying
                ? AppStrings.getString('pause', currentLocale)
                : AppStrings.getString('play', currentLocale)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    } else if (widget.existingVideo != null) {
      // Show thumbnail while video is loading
      return Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(_getVideoThumbnailUrl(widget.existingVideo!.videoUrl)),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.getString('loadingVideo', currentLocale),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                AppStrings.getString('noVideoSelected', currentLocale),
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  String _getVideoThumbnailUrl(String videoUrl) {
    // For YouTube videos
    if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
      final videoId = videoUrl.contains('youtube.com')
          ? videoUrl.split('v=')[1].split('&')[0]
          : videoUrl.split('/').last;
      return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
    }

    // For other videos, you would need to generate thumbnails on upload
    // For now, using a placeholder
    return 'https://placehold.co/600x400/${AppColors.mainColor.value.toRadixString(16).substring(2)}/white?text=Video+Preview';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Consumer<TutorialVideoProvider>(
      builder: (context, tutorialProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              widget.existingVideo != null
                  ? AppStrings.getString('editTutorialVideo', currentLocale)
                  : AppStrings.getString('uploadTutorialVideo', currentLocale),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(CupertinoIcons.back, color: Colors.white)
            ),
            backgroundColor: AppColors.mainColor,
            centerTitle: true,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.existingVideo != null
                        ? AppStrings.getString('editTutorialVideo', currentLocale)
                        : AppStrings.getString('newTutorialVideo', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.existingVideo != null
                        ? AppStrings.getString('updateInstructionalVideo', currentLocale)
                        : AppStrings.getString('uploadInstructionalVideos', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildVideoPreview(currentLocale),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.video_library),
                          label: Text(
                            widget.existingVideo != null
                                ? AppStrings.getString('replaceVideo', currentLocale)
                                : AppStrings.getString('chooseVideo', currentLocale),
                            style: GoogleFonts.poppins(),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.mainColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: tutorialProvider.isUploading ? null : _pickVideo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: AppStrings.getString('videoTitle', currentLocale),
                      hintText: AppStrings.getString('videoTitleHint', currentLocale),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.mainColor),
                      ),
                      labelStyle: GoogleFonts.poppins(),
                    ),
                    style: GoogleFonts.poppins(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.getString('pleaseEnterTitle', currentLocale);
                      }
                      return null;
                    },
                    enabled: !tutorialProvider.isUploading,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: AppStrings.getString('description', currentLocale),
                      hintText: AppStrings.getString('descriptionHint', currentLocale),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.mainColor),
                      ),
                      labelStyle: GoogleFonts.poppins(),
                    ),
                    style: GoogleFonts.poppins(),
                    enabled: !tutorialProvider.isUploading,
                  ),
                  const SizedBox(height: 32),

                  if (tutorialProvider.isUploading) ...[
                    LinearProgressIndicator(
                      value: tutorialProvider.uploadProgress,
                      backgroundColor: Colors.grey[200],
                      color: AppColors.mainColor,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${tutorialProvider.currentOperation}: ${(tutorialProvider.uploadProgress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(
                        color: AppColors.mainColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: tutorialProvider.isUploading ? null : _uploadVideo,
                      child: Text(
                        tutorialProvider.isUploading
                            ? '${tutorialProvider.currentOperation}...'
                            : widget.existingVideo != null
                            ? AppStrings.getString('updateTutorialVideo', currentLocale)
                            : AppStrings.getString('uploadTutorialVideo', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}