import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import '../../provider/splash_provider.dart';
import '../auth/intro_slider.dart';


class SubAdminSplashScreen extends StatefulWidget {
  const SubAdminSplashScreen({super.key});

  @override
  State<SubAdminSplashScreen> createState() => _SubAdminSplashScreenState();
}

class _SubAdminSplashScreenState extends State<SubAdminSplashScreen> with TickerProviderStateMixin {
  late AnimationController _meuzzeinController;
  late AnimationController _descriptionController;
  late Animation<Offset> _meuzzeinOffset;
  late Animation<Offset> _descriptionOffset;

  @override
  void initState() {
    super.initState();

    final provider = context.read<SplashScreenProvider>();

    Future.delayed(const Duration(milliseconds: 500), provider.startLogoAnimation);
    Future.delayed(const Duration(milliseconds: 1500), provider.startTextAnimation);

    Future.delayed(const Duration(seconds: 5), () {
      provider.setFinalState();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroScreen()),
      );
    });

    _meuzzeinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _descriptionController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _meuzzeinOffset = Tween<Offset>(
      begin: const Offset(-5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _meuzzeinController,
      curve: Curves.easeOut,
    ));

    _descriptionOffset = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _descriptionController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 1700), _meuzzeinController.forward);
    Future.delayed(const Duration(milliseconds: 2000), _descriptionController.forward);
  }


  @override
  void dispose() {
    _meuzzeinController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashScreenProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/bggg.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(seconds: 1),
                curve: Curves.easeOut,
                top: provider.animateLogo ? 50 : -200,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/white_logo.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 220),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DefaultTextStyle(
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              'Rafahiya Tourism',
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          totalRepeatCount: 1,
                          displayFullTextOnTap: true,
                          stopPauseOnTap: true,
                        ),
                      ),

                      const SizedBox(height: 20),
                      SlideTransition(
                        position: _meuzzeinOffset,
                        child: Text(
                          'Meuzzein',
                          style: GoogleFonts.pottaOne(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      SlideTransition(
                        position: _descriptionOffset,
                        child: Text(
                          'Your Dream App for your\n   Masjid Connectivity &\n    Salah Time updates',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
