import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/view/auth/edit_profile.dart';
import 'package:rafahiyatourism/view/more_items/setting_screen.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/app_setting_provider.dart';
import 'package:rafahiyatourism/view/user_side_contact_page.dart';
import 'package:rafahiyatourism/view/user_terms_condition_screen.dart';

import '../const/color.dart';
import '../const/shimmer_loading_text.dart';
import '../provider/locale_provider.dart';
import '../provider/user_profile_provider.dart';
import 'home/about_pdf_viewer.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      provider.fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final user = profileProvider.user;

    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    double screenWidth = MediaQuery.of(context).size.height / 1.2;
    double drawerHeight = MediaQuery.of(context).size.height / 1.2;
    double drawerWidth = MediaQuery.of(context).size.width / 1.1;
    double drawerSmallHeight = MediaQuery.of(context).size.height / 1.1;
    final isSmallScreen = screenWidth < 400;
    return Stack(
      children: [
        Container(
          color: Colors.transparent,

          height: isSmallScreen ? drawerSmallHeight : drawerHeight,
          width: isSmallScreen ? drawerWidth : screenWidth,
          child: Drawer(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  height:
                      isSmallScreen
                          ? MediaQuery.of(context).size.height / 1.1
                          : MediaQuery.of(context).size.height / 1.3,
                  width:
                      isSmallScreen
                          ? MediaQuery.of(context).size.width / 1.1
                          : MediaQuery.of(context).size.width / 1.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    image: DecorationImage(
                      image: AssetImage("assets/images/background.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        margin: EdgeInsets.only(left: 20),
                        height: isSmallScreen ? 25 : 30,
                        width: isSmallScreen ? 25 : 30,
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(
                          CupertinoIcons.back,
                          color: AppColors.whiteColor,
                          size: isSmallScreen ? 22 : 25,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    user?.fullName != null
                        ? Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        user!.fullName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 12 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : ShimmerText(
                      width: isSmallScreen ? 120 : 180,
                      height: isSmallScreen ? 16 : 24,
                      margin: const EdgeInsets.only(left: 20),
                    ),
                    user?.email != null
                        ? Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        user!.email,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 10 : 14,
                        ),
                      ),
                    )
                        : ShimmerText(
                      width: isSmallScreen ? 160 : 200,
                      height: isSmallScreen ? 12 : 16,
                      margin: const EdgeInsets.only(left: 20, top: 4),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.home,
                            color: Colors.white,
                            size: isSmallScreen ? 17 : 25,
                          ),
                          title: Text(
                            AppStrings.getString('navHome', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text(
                            AppStrings.getString('profile', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          leading: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: isSmallScreen ? 17 : 25,
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> EditProfileScreen()));
                          },
                        ),
                        ListTile(
                          title: Text(
                            AppStrings.getString('about', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          leading: Icon(
                            Icons.info_rounded,
                            color: Colors.white,
                            size: isSmallScreen ? 17 : 25,
                          ),
                          onTap: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.mainColor,
                                ),
                              ),
                            );

                            await Future.delayed(Duration(milliseconds: 300));


                            final provider = Provider.of<AppSettingsProvider>(context, listen: false);
                            await provider.fetchAboutPdfUrl();

                            final pdfUrl = provider.aboutPdfUrl;

                            Navigator.of(context).pop(); // Close loading dialog

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfViewerScreen(pdfUrl: pdfUrl),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            AppStrings.getString('settings', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          leading: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: isSmallScreen ? 17 : 25,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingScreen(),
                              ),
                            );
                          },
                        ),

                        ListTile(
                          title: Text(
                            AppStrings.getString('notifications', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          leading: Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: isSmallScreen ? 17 : 25,
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          title: Text(
                            AppStrings.getString('termAndConditions', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          leading: Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                            size: isSmallScreen ? 17 : 25,
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> UserTermsConditionsScreen()));
                          },
                        ),

                        ListTile(
                          title: Text(
                            AppStrings.getString('contact', currentLocale),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          leading: Icon(
                            Icons.call,
                            color: Colors.white,
                            size: isSmallScreen ? 17 : 25,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserContactPage(),
                              ),
                            );
                          },
                        ),

                        // Share App
                        ListTile(
                          title: Text(
                            AppStrings.getString('shareApp', currentLocale),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          leading: Icon(
                            Icons.share,
                            color: Colors.white,
                            size: isSmallScreen ? 17 : 25,
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: drawerWidth - 110,
          child: CircleAvatar(
            radius: 55,
            backgroundImage: AssetImage("assets/images/circle.png"),
            child: CircleAvatar(
              radius: 46,
              backgroundImage: user?.profileImage != null && user!.profileImage!.isNotEmpty
                  ? NetworkImage(user.profileImage!) as ImageProvider
                  : AssetImage("assets/images/user.png"),
            ),
          ),
        ),
      ],
    );
  }
}
