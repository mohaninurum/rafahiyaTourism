import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rafahiyatourism/view/auth/welcome_screen.dart';

import '../super_admin_code/superadminprovider/app_setting_provider.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch Firestore content when screen initializes
    Future.microtask(() =>
        Provider.of<AppSettingsProvider>(context, listen: false)
            .fetchIntroContent());
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600 && screenWidth < 900;
    final isExtraLargeScreen = screenWidth >= 900;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        body: Container(
          height: screenHeight,
          width: screenWidth,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Consumer<AppSettingsProvider>(
            builder: (context, provider, child) {
              final isLoading = provider.introTitle.isEmpty &&
                  provider.introTagline.isEmpty &&
                  provider.introDescription.isEmpty &&
                  provider.introSecondaryDescription.isEmpty;

              return SafeArea(
                child: Column(
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/white_logo.png',
                      height: isExtraLargeScreen
                          ? 240
                          : isLargeScreen
                          ? 200
                          : isMediumScreen
                          ? 180
                          : screenHeight * 0.16,
                    ),
                    const SizedBox(height: 50),

                    // Title
                    isLoading
                        ? _buildContainerShimmer(
                      width: screenWidth * 0.7,
                      height: isExtraLargeScreen
                          ? 50
                          : isLargeScreen
                          ? 44
                          : isMediumScreen
                          ? 36
                          : 32,
                    )
                        : Text(
                      provider.introTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: isExtraLargeScreen
                            ? 42
                            : isLargeScreen
                            ? 36
                            : isMediumScreen
                            ? 28
                            : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black54,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tagline
                    isLoading
                        ? Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: _buildContainerShimmer(
                          width: screenWidth * 0.4,
                          height: isExtraLargeScreen
                              ? 30
                              : isLargeScreen
                              ? 26
                              : isMediumScreen
                              ? 24
                              : 22,
                        ),
                      ),
                    )
                        : Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: Text(
                          provider.introTagline,
                          style: GoogleFonts.poppins(
                            fontSize: isExtraLargeScreen
                                ? 24
                                : isLargeScreen
                                ? 20
                                : isMediumScreen
                                ? 18
                                : 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: const [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black54,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    isLoading
                        ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          _buildContainerShimmer(
                            width: screenWidth * 0.9,
                            height: isExtraLargeScreen
                                ? 24
                                : isLargeScreen
                                ? 22
                                : isMediumScreen
                                ? 20
                                : 18,
                          ),
                          const SizedBox(height: 8),
                          _buildContainerShimmer(
                            width: screenWidth * 0.8,
                            height: isExtraLargeScreen
                                ? 24
                                : isLargeScreen
                                ? 22
                                : isMediumScreen
                                ? 20
                                : 18,
                          ),
                          const SizedBox(height: 8),
                          _buildContainerShimmer(
                            width: screenWidth * 0.7,
                            height: isExtraLargeScreen
                                ? 24
                                : isLargeScreen
                                ? 22
                                : isMediumScreen
                                ? 20
                                : 18,
                          ),
                        ],
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        provider.introDescription,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isExtraLargeScreen
                              ? 22
                              : isLargeScreen
                              ? 20
                              : isMediumScreen
                              ? 18
                              : 16,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFFCE4D0),
                          fontWeight: FontWeight.w500,
                          shadows: const [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black54,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Secondary Description
                    isLoading
                        ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          _buildContainerShimmer(
                            width: screenWidth * 0.8,
                            height: isExtraLargeScreen
                                ? 24
                                : isLargeScreen
                                ? 22
                                : isMediumScreen
                                ? 20
                                : 18,
                          ),
                          const SizedBox(height: 8),
                          _buildContainerShimmer(
                            width: screenWidth * 0.7,
                            height: isExtraLargeScreen
                                ? 24
                                : isLargeScreen
                                ? 22
                                : isMediumScreen
                                ? 20
                                : 18,
                          ),
                        ],
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        provider.introSecondaryDescription,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isExtraLargeScreen
                              ? 22
                              : isLargeScreen
                              ? 20
                              : isMediumScreen
                              ? 18
                              : 16,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFFCE4D0),
                          fontWeight: FontWeight.w500,
                          shadows: const [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black54,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom button
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(
            bottom: isSmallScreen ? 30 : 40,
          ),
          child: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              );
            },
            child: Container(
              height: isExtraLargeScreen
                  ? 70
                  : isLargeScreen
                  ? 60
                  : isMediumScreen
                  ? 50
                  : 48,
              width: screenWidth * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Let\'s get connected',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFF32020),
                    fontWeight: FontWeight.bold,
                    fontSize: isExtraLargeScreen
                        ? 26
                        : isLargeScreen
                        ? 22
                        : isMediumScreen
                        ? 20
                        : 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Container-based shimmer widget
  Widget _buildContainerShimmer({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade200,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}