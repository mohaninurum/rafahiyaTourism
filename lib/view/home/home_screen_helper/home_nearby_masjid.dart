
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/home_masjid_data_provider.dart';
import 'package:rafahiyatourism/provider/multi_mosque_provider.dart';
import 'package:rafahiyatourism/provider/nearby_mosque_provider.dart';
import 'package:rafahiyatourism/view/home/home_screen_helper/special_timing_section.dart';

import '../../../const/prayer_time_section.dart';
import '../../../utils/widgets/nearby_mosque_dialogue.dart';
import '../../super_admin_code/superadminprovider/marquee/marquee_provider.dart';
import '../masjid_settings_screen.dart';
import 'home_announcements_section.dart';
import 'home_masjid_info_card.dart';
import 'home_masjid_info_header.dart';
import 'jummah_eid_prayer_section.dart';

class NearByMasjid extends StatefulWidget {
  final int tabIndex;
  const NearByMasjid({super.key,required this.tabIndex});

  @override
  State<NearByMasjid> createState() => _NearByMasjidState();
}

class _NearByMasjidState extends State<NearByMasjid> {
  bool _hasSelectedMosque = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _checkIfMosqueSelected();
  }

  void _checkIfMosqueSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final multiProvider = Provider.of<MultiMosqueProvider>(context, listen: false);
      final mosqueData = multiProvider.getMosqueData(2); // Index 2 for nearby masjid

      if (mosqueData != null && mosqueData['uid'] != null) {
        setState(() {
          _hasSelectedMosque = true;
          _isInitializing = false;
        });

        // Fetch mosque data
        final homeDataProvider = Provider.of<HomeMasjidDataProvider>(context, listen: false);
        homeDataProvider.fetchMosqueData(2, mosqueData['uid']);
      } else {
        setState(() {
          _hasSelectedMosque = false;
          _isInitializing = false;
        });

        // Auto-show dialog if no mosque is selected
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showNearbyMosqueDialog();
        });
      }
    });
  }

  Future<void> _showNearbyMosqueDialog() async {
    await showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (context) => NearbyMosqueProvider(),
        child: NearbyMosqueDialog(
          onMosqueSelected: (mosqueUid, mosqueData) async {
            Navigator.of(context).pop();
            await _handleMosqueSelection(mosqueUid, mosqueData);
          },
          onDismissed: () {

            if (!_hasSelectedMosque) {
              final multiProvider = Provider.of<MultiMosqueProvider>(context, listen: false);
              final existingData = multiProvider.getMosqueData(2);
              if (existingData != null && existingData['uid'] != null) {
                setState(() {
                  _hasSelectedMosque = true;
                });
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _handleMosqueSelection(String mosqueUid, Map<String, dynamic> mosqueData) async {
    final multiProvider = Provider.of<MultiMosqueProvider>(context, listen: false);
    final homeDataProvider = Provider.of<HomeMasjidDataProvider>(context, listen: false);

    // Save to MultiMosqueProvider for tab index 2
    multiProvider.setMosqueData(2, {
      'uid': mosqueUid,
      'name': mosqueData['masjidName'] ?? 'Unknown Mosque',
      'address': mosqueData['address'] ?? 'No address',
      'phone': mosqueData['mobileNumber'] ?? '+917741807861',
      'location': mosqueData['location'],
    });

    // Save to Firestore
    await multiProvider.saveToFirestore();

    // Fetch mosque data
    await homeDataProvider.fetchMosqueData(2, mosqueUid);

    setState(() {
      _hasSelectedMosque = true;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mosque selected successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _changeMosque() {
    setState(() {
      _hasSelectedMosque = false;
    });

    _showNearbyMosqueDialog();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.mainColor),
        ),
      );
    }

    if (!_hasSelectedMosque) {
      return _buildSelectionScreen();
    }

    return _buildMasjidView();
  }

  Widget _buildSelectionScreen() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              height: 30,
              color: AppColors.mainColor,
              child: Marquee(
                text: 'Select a nearby mosque to view prayer times and announcements',
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
            SizedBox(height: 100),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mosque,
                    size: 100,
                    color: AppColors.mainColor.withOpacity(0.3),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No Mosque Selected',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Choose a mosque near your location to see prayer times, announcements, and other details',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _showNearbyMosqueDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Find Nearby Mosques',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      // Option to manually select a mosque if location is not working
                      _showNearbyMosqueDialog();
                    },
                    child: Text(
                      'Search All Mosques',
                      style: GoogleFonts.poppins(
                        color: AppColors.mainColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasjidView() {
    final homeMasjidDataProvider = Provider.of<HomeMasjidDataProvider>(context);

    return Consumer<MarqueeProvider>(
      builder: (context, marqueeProvider, child) {
        return Column(
          children: [
            // Change Mosque Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.mainColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearby mosque',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.mainColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _changeMosque,
                        child: Text(
                          'Change Mosque >',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.mainColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MasjidSettingsScreen(tabIndex: widget.tabIndex),
                          ),
                        );
                      }, icon: Icon(Icons.settings,color: AppColors.mainColor,))
                    ],
                  ),

                ],
              ),
            ),

            // Mosque Details
            Expanded(
              child: SingleChildScrollView(
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
                    MasjidInfoHeader(tabIndex: 2),
                    MasjidInfoCard(tabIndex: 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: PrayerTimesSection(tabIndex: 2),
                        ),
                        _buildFridayEidSection(context),
                        const SizedBox(height: 20),
                        SpecialTimingsSection(tabIndex: 2),
                        const SizedBox(height: 20),
                        AnnouncementsSection(
                          tabIndex: 2,
                          dataProvider: homeMasjidDataProvider,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFridayEidSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, top: 15, bottom: 8),
      child: Column(
        children: [
          JummahEidPrayerSection(tabIndex: 2),
        ],
      ),
    );
  }
}