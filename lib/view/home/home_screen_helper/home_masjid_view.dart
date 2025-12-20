import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/home_masjid_data_provider.dart';
import 'package:rafahiyatourism/view/home/home_screen_helper/special_timing_section.dart';
import '../../../const/prayer_time_section.dart';
import '../../super_admin_code/superadminprovider/marquee/marquee_provider.dart';
import 'home_announcements_section.dart';
import 'home_masjid_info_card.dart';
import 'home_masjid_info_header.dart';
import 'jummah_eid_prayer_section.dart';

class MasjidView extends StatefulWidget {
  final int tabIndex;

  const MasjidView({super.key, required this.tabIndex});

  @override
  State<MasjidView> createState() => _MasjidViewState();
}

class _MasjidViewState extends State<MasjidView> {
  @override
  Widget build(BuildContext context) {
    final homeMasjidDataProvider = Provider.of<HomeMasjidDataProvider>(context);

    return Consumer<MarqueeProvider>(
        builder: (context, marqueeProvider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Marquee Section with real-time updates
                Container(
                  height: 30,
                  color: AppColors.mainColor,
                  child: marqueeProvider.isLoading
                      ? Center(
                    child: SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                      : Marquee(
                    text: marqueeProvider.marqueeText,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: AppColors.whiteColor,
                      fontSize: 14,
                    ),
                    velocity: 40.0,
                    blankSpace: 100.0,
                    pauseAfterRound: const Duration(seconds: 1),
                    startPadding: 10.0,
                  ),
                ),
                MasjidInfoHeader(tabIndex: widget.tabIndex),
                MasjidInfoCard(tabIndex: widget.tabIndex),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: PrayerTimesSection(tabIndex: widget.tabIndex),
              ),
              _buildFridayEidSection(context),
              const SizedBox(height: 20),
              SpecialTimingsSection(tabIndex: widget.tabIndex),
              const SizedBox(height: 20),
               AnnouncementsSection(
                 tabIndex: widget.tabIndex,
                 dataProvider: homeMasjidDataProvider,),
              const SizedBox(height: 20),
            ],
          ),
              ],
            ),
          );
        },
    );
  }

  Widget _buildFridayEidSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0,right: 8,top: 15,bottom: 8),
      child: Column(
        children: [
          JummahEidPrayerSection(tabIndex: widget.tabIndex),
        ],
      ),
    );
  }
}

