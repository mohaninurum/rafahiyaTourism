import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../const/color.dart';
import '../../../../provider/locale_provider.dart';
import '../../../../utils/language/app_strings.dart';
import '../../data/subAdminProvider/bayan_provider.dart';
import '../../data/utils/circular_indicator_spinkit.dart';
import '../widgets/share_bayan_dialog.dart';
import 'announcement_tile.dart';

class AdminGeneralAnnouncementScreen extends StatefulWidget {
  const AdminGeneralAnnouncementScreen({super.key});

  @override
  State<AdminGeneralAnnouncementScreen> createState() => _AdminGeneralAnnouncementScreenState();
}

class _AdminGeneralAnnouncementScreenState extends State<AdminGeneralAnnouncementScreen> {
  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<BayanProvider>().fetchBayanAnnouncements());
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ShareBayanDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: AppColors.featherGrey,
      appBar: AppBar(
        title: Text(
          AppStrings.getString('generalAnnouncements', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.blackBackground,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.blackBackground,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.mainColor),
            onPressed: () => _showAddAnnouncementDialog(context),
            tooltip: AppStrings.getString('addAnnouncement', currentLocale),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAnnouncementDialog(context),
        backgroundColor: AppColors.mainColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: AppStrings.getString('addAnnouncement', currentLocale),
      ),
      body: Consumer<BayanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CustomCircularProgressIndicator(
                size: 50,
                color: AppColors.mainColor,
                spinKitType: SpinKitType.chasingDots,
              ),
            );
          }
          if (provider.announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.announcement_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.getString('noAnnouncementsAvailable', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.getString('tapPlusToAdd', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAnnouncementDialog(context),
                    icon: const Icon(Icons.add),
                    label: Text(AppStrings.getString('addFirstAnnouncement', currentLocale)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
            child: ListView.separated(
              itemCount: provider.announcements.length,
              separatorBuilder: (_, __) => const Divider(height: 10),
              itemBuilder: (context, index) {
                return AnnouncementTile(
                  announcement: provider.announcements[index],
                  docId: provider.announcements[index].id,
                );
              },
            ),
          );
        },
      ),
    );
  }
}