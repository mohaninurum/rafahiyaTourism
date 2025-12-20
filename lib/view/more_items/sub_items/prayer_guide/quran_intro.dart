import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import '../../../../provider/locale_provider.dart';
import 'combined_quran.dart';

class QuranIntroScreen extends StatefulWidget {
  const QuranIntroScreen({super.key});

  @override
  State<QuranIntroScreen> createState() => _QuranIntroScreenState();
}

class _QuranIntroScreenState extends State<QuranIntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textOpacityAnimation;

  bool _showContent = false;
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation sequence
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.forward();
    });

    // Show content after initial animation
    Timer(const Duration(milliseconds: 1500), () {
      setState(() => _showContent = true);
    });

    // Complete animation and navigate
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _animationCompleted = true);
        _navigateToMainScreen();
      }
    });
  }

  void _navigateToMainScreen() {
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 2000),
          pageBuilder: (_, __, ___) => const CombinedQuranScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Quran in Arabic with animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  'القرآن الكريم',
                  style: GoogleFonts.amiri(
                    fontSize: 48,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Lottie animation (book opening)
              if (_showContent)
                FadeTransition(
                  opacity: _textOpacityAnimation,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/book.json',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.book, size: 100, color: Colors.white);
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // English title with fade in
              if (_showContent)
                FadeTransition(
                  opacity: _textOpacityAnimation,
                  child: Text(
                  AppStrings.getString('holyQuran', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Subtitle with fade in
              if (_showContent)
                FadeTransition(
                  opacity: _textOpacityAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      AppStrings.getString('introQuranGuide', currentLocale),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // Lottie loader when animation completes
              if (_animationCompleted)
                Column(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Lottie.asset(
                        'assets/animation/book.json',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.getString('recitePrepare', currentLocale),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
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