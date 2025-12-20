import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/view/more_items/qibla_finder_screen.dart';
import 'package:rafahiyatourism/view/more_items/community_services_screen.dart';
import 'package:rafahiyatourism/view/more_items/subitem_screen.dart';
import 'package:rafahiyatourism/view/more_items/tasbih_screen.dart';
import 'package:rafahiyatourism/view/more_items/umrah_kit_package_screen.dart';
import 'package:rafahiyatourism/view/more_items/zakat_calculator_screen.dart';

import '../../const/color.dart';
import 'currency_convertor_page.dart';
import 'nuzuk_app_screen.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class MoreItemsScreen extends StatefulWidget {
  const MoreItemsScreen({super.key});

  @override
  State<MoreItemsScreen> createState() => _MoreItemsScreenState();
}

class _MoreItemsScreenState extends State<MoreItemsScreen> {
  final List<Map<String, dynamic>> mainItems = [
    {
      'titleKey': 'prayersGuide',
      'icon': Icons.menu_book,
      'subItems': [
        {'titleKey': 'howtoPraySalah', 'icon': Icons.accessibility_new},
        {'titleKey': 'surahList', 'icon': Icons.library_books},
        {'titleKey': 'duaList', 'icon': Icons.record_voice_over},
        {'titleKey': 'readMaulana', 'icon': Icons.mosque},
      ],
    },
    {
      'titleKey': 'rafahiyaGuide',
      'icon': Icons.map,
      'subItems': [
        {'titleKey': 'faqs', 'icon': Icons.help_outline},
        {'titleKey': 'makkahTV', 'icon': Icons.live_tv},
        {'titleKey': 'madinahTV', 'icon': Icons.live_tv},
        {'titleKey': 'tutorialVideos', 'icon': Icons.video_library},
        {'titleKey': 'adahiBooking', 'icon': Icons.shopping_cart},
      ],
    },
    {
      'titleKey': 'umrahKit',
      'icon': Icons.backpack,
      'subItems': [],
    },
    {
      'titleKey': 'qiblaFinder',
      'icon': Icons.compass_calibration,
      'subItems': [],
    },
    {
      'titleKey': 'tasbi',
      'icon': Icons.smart_button_rounded,
      'subItems': [],
    },
    {
      'titleKey': 'zakatCalculator',
      'icon': Icons.calculate,
      'subItems': [],
    },
    {
      'titleKey': 'currencyConvertor',
      'icon': Icons.currency_exchange,
      'subItems': [],
    },
    {
      'titleKey': 'communityServices',
      'icon': Icons.miscellaneous_services,
      'subItems': [],
    },
    {
      'titleKey': 'nuzukApp',
      'icon': Icons.apps,
      'subItems': [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          AppStrings.getString('moreItems', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: mainItems.length,
          itemBuilder: (context, index) {
            final item = mainItems[index];
            final List<Map<String, dynamic>> subItems = List<Map<String, dynamic>>.from(item['subItems']);
            final localizedTitle = AppStrings.getString(item['titleKey'], currentLocale);

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  final subItems = item['subItems'] as List?;

                  if (subItems != null && subItems.isNotEmpty) {
                    // Localize subitems before passing
                    final localizedSubItems = subItems.map((subItem) {
                      return {
                        'title': AppStrings.getString(subItem['titleKey'], currentLocale),
                        'icon': subItem['icon'],
                      };
                    }).toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubItemsScreen(
                          title: localizedTitle,
                          subItems: localizedSubItems.cast<Map<String, dynamic>>(),
                        ),
                      ),
                    );
                  } else {
                    // Navigate to specific screens based on title key
                    switch (item['titleKey']) {
                      case 'qiblaFinder':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QiblaFinderScreen()),
                        );
                        break;
                      case 'tasbi':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TasbiScreen()),
                        );
                        break;
                      case 'zakatCalculator':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ZakatCalculatorScreen()),
                        );
                        break;
                      case 'communityServices':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CommunityServicesScreen()),
                        );
                        break;
                      case 'currencyConvertor':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CurrencyConverterPage()),
                        );
                        break;
                      case 'nuzukApp':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NuzukAppScreen()),
                        );
                        break;
                      case 'umrahKit':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UmrahKitPackageScreen()),
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
                },
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/container_image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          item['titleKey'] == 'tasbi'
                              ? Image.asset(
                            'assets/images/tasbih.png',
                            width: 60,
                            height: 60,
                            color: Colors.white,
                          )
                              : Icon(
                            item['icon'],
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizedTitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
}