import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/view/more_items/sub_items/prayer_guide/dua_list_screen.dart';
import 'package:rafahiyatourism/view/more_items/sub_items/prayer_guide/how_to_pray_screen.dart';
import 'package:rafahiyatourism/view/more_items/sub_items/prayer_guide/quran_intro.dart';
import 'package:rafahiyatourism/view/more_items/sub_items/prayer_guide/combined_quran.dart';
import 'package:rafahiyatourism/view/more_items/sub_items/prayer_guide/surah_list_screen.dart';
import 'package:rafahiyatourism/view/more_items/sub_items/rafahiya_guide/FAQs.dart';
import 'package:rafahiyatourism/view/more_items/sub_items/rafahiya_guide/adahi_qurbani_screen.dart';
import 'package:rafahiyatourism/view/more_items/sub_items/rafahiya_guide/live_madinah_tv_screen.dart';
import 'package:rafahiyatourism/view/more_items/sub_items/rafahiya_guide/live_makkah_tv_screen.dart';
import 'package:rafahiyatourism/view/more_items/sub_items/rafahiya_guide/tutorial_videos_screen.dart';
import '../../const/color.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class SubItemsScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> subItems;

  const SubItemsScreen({
    super.key,
    required this.title,
    required this.subItems,
  });

  @override
  State<SubItemsScreen> createState() => _SubItemsScreenState();
}

class _SubItemsScreenState extends State<SubItemsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideTextAnimation;
  late Animation<double> _slideIconAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Slower duration
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut), // Text appears first
      ),
    );

    _slideTextAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut), // Text slides slower
      ),
    );

    _slideIconAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut), // Icon appears later
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(CupertinoIcons.back, color: Colors.white),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: widget.subItems.isEmpty
          ? Center(
        child: Text(
          AppStrings.getString('noItemsAvailable', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        itemCount: widget.subItems.length,
        itemBuilder: (context, index) {
          final sub = widget.subItems[index];
          return _buildListItem(sub, isSmallScreen, currentLocale);
        },
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> sub, bool isSmallScreen, String currentLocale) {
    return InkWell(
      onTap: () {
        _navigateToScreen(sub['title'], currentLocale);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 8 : 12,
                ),
                child: Row(
                  children: [
                    Transform.translate(
                      offset: Offset(_slideTextAnimation.value, 0),
                      child: CircleAvatar(
                        radius: isSmallScreen ? 18 : 22,
                        backgroundColor: AppColors.mainColor.withOpacity(0.1),
                        child: Icon(
                          sub['icon'],
                          size: isSmallScreen ? 20 : 24,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Transform.translate(
                        offset: Offset(_slideTextAnimation.value, 0),
                        child: Text(
                          sub['title'],
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(_slideIconAnimation.value, 0),
                      child: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToScreen(String title, String currentLocale) {
    // Create a reverse mapping from localized titles to original keys
    final Map<String, String> titleToKeyMap = {
      AppStrings.getString('howtoPraySalah', currentLocale): 'howtoPraySalah',
      AppStrings.getString('surahList', currentLocale): 'surahList',
      AppStrings.getString('duaList', currentLocale): 'duaList',
      AppStrings.getString('readMaulana', currentLocale): 'readMaulana',
      AppStrings.getString('faqs', currentLocale): 'faqs',
      AppStrings.getString('makkahTV', currentLocale): 'makkahTV',
      AppStrings.getString('madinahTV', currentLocale): 'madinahTV',
      AppStrings.getString('tutorialVideos', currentLocale): 'tutorialVideos',
      AppStrings.getString('adahiBooking', currentLocale): 'adahiBooking',
    };

    // Get the original key from the localized title
    final originalKey = titleToKeyMap[title] ?? title;

    // Navigate based on the original key
    switch (originalKey) {
      case 'howtoPraySalah':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HowToPrayScreen(),
          ),
        );
        break;
      case 'surahList':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahListScreen(),
          ),
        );
        break;
      case 'duaList':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DuaListScreen(),
          ),
        );
        break;
      case 'readMaulana':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuranIntroScreen(),
          ),
        );
        break;
      case 'faqs':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FaqsScreen(),
          ),
        );
        break;
      case 'makkahTV':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveMakkahTvScreen(),
          ),
        );
        break;
      case 'madinahTV':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveMadinahTvScreen(),
          ),
        );
        break;
      case 'tutorialVideos':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TutorialVideosScreen(),
          ),
        );
        break;
      case 'adahiBooking':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdahiQurbaniScreen(),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.getString('featureSoon', currentLocale),
            ),
          ),
        );
    }
  }
}