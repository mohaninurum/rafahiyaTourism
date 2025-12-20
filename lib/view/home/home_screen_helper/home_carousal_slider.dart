import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/home_images_slider_provider/home_slider_images_provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/home_images_slider_provider/slider_image_model.dart';

class HomeCarouselSlider extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isSmallScreen;

  const HomeCarouselSlider({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isSmallScreen,
  });

  @override
  State<HomeCarouselSlider> createState() => _HomeCarouselSliderState();
}

class _HomeCarouselSliderState extends State<HomeCarouselSlider> {
  int _currentIndex = 0;
  final List<String> demoImages = [
    'assets/images/slider_1.jpg',
    'assets/images/slider_2.jpg',
    'assets/images/slider_3.jpg',
    'assets/images/slider_4.jpg',
    'assets/images/slider_5.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final sliderProvider = Provider.of<SliderImagesProvider>(context);

    return Consumer<SliderImagesProvider>(
      builder: (context, sliderProvider, child) {
        return Positioned(
          top: widget.screenHeight * 0.12,
          left: 0,
          right: 0,
          child: Column(
            children: [
              if (sliderProvider.sliderImages.isNotEmpty && !sliderProvider.hasError)
                _buildFirebaseCarousel(sliderProvider.sliderImages)
              else
                _buildDemoCarousel(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFirebaseCarousel(List<SliderImage> sliderImages) {
    return CarouselSlider(
      items: sliderImages.map((sliderImage) {
        return buildCarouselItem(sliderImage.imageUrl, widget.screenWidth);
      }).toList(),
      options: CarouselOptions(
        height: widget.screenHeight * 0.2,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
        autoPlay: true,
        viewportFraction: widget.isSmallScreen ? 0.7 : 0.55,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildDemoCarousel() {
    return CarouselSlider(
      items: demoImages.map((imagePath) {
        return buildCarouselItem(imagePath, widget.screenWidth);
      }).toList(),
      options: CarouselOptions(
        height: widget.screenHeight * 0.2,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
        autoPlay: true,
        viewportFraction: widget.isSmallScreen ? 0.7 : 0.55,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
Widget buildCarouselItem(String imagePath, double screenWidth) {
  return AspectRatio(
    aspectRatio: 20 / 13,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        fit: StackFit.expand,
        children: [
          imagePath.startsWith('http')
              ? Image.network(
            imagePath,
            fit: BoxFit.fill,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                  child: Icon(Icons.error, color: Colors.red));
            },
          )
              : Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
