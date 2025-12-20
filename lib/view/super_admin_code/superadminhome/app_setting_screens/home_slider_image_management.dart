import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:intl/intl.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import '../../superadminprovider/home_images_slider_provider/home_slider_images_provider.dart';
import '../../superadminprovider/home_images_slider_provider/slider_image_model.dart';

class HomeSliderManagementScreen extends StatefulWidget {
  const HomeSliderManagementScreen({super.key});

  @override
  State<HomeSliderManagementScreen> createState() => _HomeSliderManagementScreenState();
}

class _HomeSliderManagementScreenState extends State<HomeSliderManagementScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadImages();
    });
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);
    await Provider.of<SliderImagesProvider>(context, listen: false).loadSliderImages();
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final currentLocale = _getCurrentLocale(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (mounted) {
          setState(() => _isLoading = true);
        }

        await Provider.of<SliderImagesProvider>(context, listen: false)
            .addSliderImage(File(pickedFile.path));

        // Force a reload to ensure UI updates
        await _loadImages();

        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(AppStrings.getString('imageUploadedSuccessfully', currentLocale)),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${AppStrings.getString('failedToUploadImage', currentLocale)} $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.getString('homeSliderImagesTitle', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 22 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.mainColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _loadImages,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer<SliderImagesProvider>(
          builder: (context, sliderProvider, child) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview Section
                  Text(
                    AppStrings.getString('sliderPreview', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: screenHeight * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[100],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildPreviewSlider(sliderProvider.sliderImages),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Management Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.getString('manageImages', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(
                          AppStrings.getString('addImage', currentLocale),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Images List
                  Expanded(
                    child: sliderProvider.sliderImages.isEmpty
                        ? _buildEmptyState(currentLocale)
                        : ReorderableListView.builder(
                      itemCount: sliderProvider.sliderImages.length,
                      onReorder: (oldIndex, newIndex) async {
                        setState(() => _isLoading = true);
                        try {
                          await Provider.of<SliderImagesProvider>(context, listen: false)
                              .reorderImages(oldIndex, newIndex);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${AppStrings.getString('failedToReorderImages', currentLocale)} $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      },
                      itemBuilder: (context, index) {
                        final image = sliderProvider.sliderImages[index];
                        return _buildImageCard(image, index, context, currentLocale);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPreviewSlider(List<SliderImage> images) {
    if (images.isEmpty || images.any((image) => image.imageUrl.isEmpty)) {
      return CarouselSlider(
        items: [
          'assets/images/slider_1.jpg',
          'assets/images/slider_2.jpg',
          'assets/images/slider_3.jpg',
        ].map((imagePath) {
          return buildCarouselItem(imagePath, isAsset: true);
        }).toList(),
        options: CarouselOptions(
          height: 200,
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
          autoPlay: true,
          viewportFraction: 0.8,
        ),
      );
    } else {
      return CarouselSlider(
        items: images.map((sliderImage) {
          return buildCarouselItem(sliderImage.imageUrl, isAsset: false);
        }).toList(),
        options: CarouselOptions(
          height: 200,
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
          autoPlay: true,
          viewportFraction: 0.8,
        ),
      );
    }
  }

  Widget buildCarouselItem(String imagePath, {bool isAsset = true}) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isAsset
            ? Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
        )
            : CachedNetworkImage(
          imageUrl: imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error_outline),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String currentLocale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.getString('noSliderImages', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.getString('tapToAddImage', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(SliderImage image, int index, BuildContext context, String currentLocale) {
    return Card(
      color: Colors.white,
      key: Key(image.id),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: image.imageUrl.startsWith('http')
                      ? CachedNetworkImageProvider(image.imageUrl) as ImageProvider
                      : AssetImage(image.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Image info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppStrings.getString('image', currentLocale)} ${index + 1}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppStrings.getString('uploaded', currentLocale)}: ${DateFormat('MMM dd, yyyy').format(image.uploadedAt)}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Reorder handle
            Icon(
              Icons.drag_handle,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 8),

            // Delete button
            IconButton(
              onPressed: () {
                _showDeleteDialog(image, currentLocale);
              },
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(SliderImage image, String currentLocale) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppStrings.getString('deleteImage', currentLocale),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            AppStrings.getString('confirmDeleteImage', currentLocale),
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => _isLoading = true);
                try {
                  await Provider.of<SliderImagesProvider>(context, listen: false)
                      .deleteSliderImage(image.id, image.imageUrl);

                  // Reload images after deletion
                  await _loadImages();

                  // Use the captured scaffoldMessenger instead of context
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.getString('imageDeleted', currentLocale)),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // Use the captured scaffoldMessenger instead of context
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('${AppStrings.getString('failedToDeleteImage', currentLocale)} $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                // Check if the widget is still mounted before calling setState
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              },
              child: Text(
                AppStrings.getString('delete', currentLocale),
                style: GoogleFonts.poppins(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}