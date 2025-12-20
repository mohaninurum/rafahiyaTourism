import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/utils/model/auth/auth_user_model.dart';
import 'package:rafahiyatourism/utils/services/splash_services.dart';
import 'package:rafahiyatourism/view/customer_drawer.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/home_images_slider_provider/home_slider_images_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../provider/locale_provider.dart';
import 'home_screen_helper/home_app_bar_actions.dart';
import 'home_screen_helper/home_carousal_slider.dart';
import 'home_screen_helper/home_masjid_view.dart';
import 'home_screen_helper/home_nearby_masjid.dart';

class HomeScreen extends StatefulWidget {
  final AuthUserModel? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SplashServices services = SplashServices();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    Future.microtask(() =>
        Provider.of<SliderImagesProvider>(context, listen: false).loadSliderImages());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: screenHeight * 0.43,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/container_image.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.04,
                left: screenWidth * 0.05,
                child: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: screenWidth * 0.08,
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
              Positioned(
                top: screenHeight * 0.04,
                right: screenWidth * 0.05,
                child: AppBarActions(screenWidth: screenWidth),
              ),
              HomeCarouselSlider(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                isSmallScreen: isSmallScreen,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: screenHeight * 0.07,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFD7E72).withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: screenHeight * 0.04,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Colors.white,
                            dividerColor: Colors.transparent,
                            unselectedLabelColor: Colors.black,
                            indicator: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 9 : 11,
                              fontWeight: FontWeight.w600,
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            overlayColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                            tabs:  [
                              Tab(child: Text("${AppStrings.getString('myMasjid', currentLocale)} 1",style: GoogleFonts.poppins(),)),
                              Tab(child: Text("${AppStrings.getString('myMasjid', currentLocale)} 2",style: GoogleFonts.poppins(),)),
                              Tab(child: Text(AppStrings.getString('nearbyMasjid', currentLocale),style: GoogleFonts.poppins(),)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MasjidView(tabIndex: 0),
                MasjidView(tabIndex: 1),
                NearByMasjid(tabIndex: 2,
                )],
            ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: (){
          _launchWhatsApp(currentLocale);
        },
        child: Container(
          height: 70,
          width: 70,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/whatsapp.png'),
              fit: BoxFit.cover,
            ),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }


  Future<void> _launchWhatsApp(final currentLocale) async {


    final phoneNumber = '+919552378468';
    final url = 'https://wa.me/$phoneNumber';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw '${AppStrings.getString('couldNotLaunch', currentLocale)} $url';
      }
    } catch (e) {
      print('${AppStrings.getString('errorLaunchingWhatsApp', currentLocale)}: $e');
    }
  }
}