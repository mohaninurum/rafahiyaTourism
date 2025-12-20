


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/app_setting_screens/app_setting_view.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/general_announcement.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/all_admins.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/salah_clock_super_admin_screen.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/super_admin_list.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/tutorial_video_list.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/user_location/user_location.dart';

import '../superadminprovider/pending_admin_imam_list.dart';
import '../superadminprovider/pending_hadiyah_provider/pending_hadiyah_provider.dart';
import 'add_community_service/add_community_services_super_admin.dart';
import 'add_packages_screen.dart';
import 'add_super_admin_screen.dart';
import 'admin_request_detail_screen.dart';
import 'bayan_screen.dart';
import 'date_setting_screen.dart';
import 'global_ads_screen.dart';
import 'hadiyah/handiyah_request_detail_screen.dart';

class SuperAdminHome extends StatefulWidget {
  const SuperAdminHome({super.key});

  @override
  State<SuperAdminHome> createState() => _SuperAdminHomeState();
}

class _SuperAdminHomeState extends State<SuperAdminHome> {
  final List<SalahAlert> salahAlerts = [
    SalahAlert(masjid: "Masjid Al-Haram", days: 8),
    SalahAlert(masjid: "Masjid An-Nabawi", days: 9),
  ];

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<PendingAdminImamListProvider>(
        context,
        listen: false,
      );
      adminProvider.startListening();
      adminProvider.fetchRequestUpdateTimings();

      final hadiyaProvider = Provider.of<PendingHadiyaProvider>(
        context,
        listen: false,
      );
      hadiyaProvider.startListening();
    });

  }

  @override
  void dispose() {
    Provider.of<PendingAdminImamListProvider>(
      context,
      listen: false,
    ).stopListening();
    Provider.of<PendingHadiyaProvider>(context, listen: false).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppStrings.getString('dashboard', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddSuperAdminScreen(),
                ),
              );
            },
            icon: const Icon(
              CupertinoIcons.person_add_solid,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(currentLocale),
            const SizedBox(height: 24),

            _buildQuickActions(currentLocale),
            const SizedBox(height: 24),
            Consumer<PendingAdminImamListProvider>(
              builder: (context, pendingRequestProvider, child) {
                return _buildSectionTitle(
                  AppStrings.getString('pendingAdminRequests', currentLocale),
                  pendingRequestProvider.unregisteredUsers.length,
                  currentLocale,
                );
              },
            ),

            const SizedBox(height: 8),
            _buildPendingRequests(currentLocale),
            const SizedBox(height: 24),
            Consumer<PendingHadiyaProvider>(
              builder: (context, hadiyaProvider, child) {
                return Column(
                  children: [
                    _buildSectionTitle(
                      AppStrings.getString(
                        'pendingHadiyaRequests',
                        currentLocale,
                      ),
                      hadiyaProvider.pendingHadiyaList.length,
                      currentLocale,
                    ),
                    const SizedBox(height: 8),
                    _buildPendingHadiyaRequests(hadiyaProvider, currentLocale),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(
              AppStrings.getString('salahClockAlerts', currentLocale),
              salahAlerts.length,
              currentLocale,
            ),
            const SizedBox(height: 8),
            _buildSalahAlerts(currentLocale),
            const SizedBox(height: 24),
            _buildSectionTitle(
              AppStrings.getString('applicationStatistics', currentLocale),
              0,
              currentLocale,
            ),
            const SizedBox(height: 8),
            _buildStatisticsGrid(currentLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String currentLocale) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream:
      userId != null
          ? FirebaseFirestore.instance
          .collection('super_admins')
          .doc(userId)
          .snapshots()
          : null,
      builder: (context, snapshot) {
        final name =
            snapshot.data?['name'] as String? ??
                AppStrings.getString('superAdmin', currentLocale);
        print('Name of Super $name');
        final email =
            snapshot.data?['email'] as String? ??
                AppStrings.getString('superAdmin', currentLocale);
        // final lastLogin = snapshot.data?['lastLogin'] as Timestamp?;

        // String lastLoginText = AppStrings.getString(
        //   'lastLoginNever',
        //   currentLocale,
        // );
        // if (lastLogin != null) {
        //   final formattedDate = DateFormat(
        //     'MMM d, y - h:mm a',
        //   ).format(lastLogin.toDate());
        //   lastLoginText =
        //       '${AppStrings.getString('lastLogin', currentLocale)}: $formattedDate';
        // }

        return Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.mainColor,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${AppStrings.getString('welcome', currentLocale)}, $name",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
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
    );
  }

  Widget _buildQuickActions(String currentLocale) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 0.9,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildActionButton(
          Icons.people,
          AppStrings.getString('admins', currentLocale),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllAdminsScreen()),
            );
          },
        ),

        _buildActionButton(
          Icons.access_time,
          AppStrings.getString('salahClock', currentLocale),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SalahClockScreen()),
            );
          },
        ),
        _buildActionButton(
          Icons.date_range,
          AppStrings.getString('dateSettings', currentLocale),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DateSettingsScreen(),
              ),
            );
          },
        ),
        _buildActionButton(
          Icons.ads_click,
          AppStrings.getString('globalAds', currentLocale),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GlobalAdsScreen()),
            );
          },
        ),
        _buildActionButton(
          Icons.video_collection,
          AppStrings.getString('uploadTutorials', currentLocale),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TutorialVideosListScreen(),
              ),
            );
          },
        ),
        _buildActionButton(
          Icons.tour,
          AppStrings.getString('packages', currentLocale),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddPackagesScreen(),
              ),
            );
          },
        ),
        _buildActionButton(
          Icons.announcement,
          AppStrings.getString('generalAnnouncements', currentLocale),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GeneralAnnouncementScreen(),
              ),
            );
          },
        ),
        _buildActionButton(
          CupertinoIcons.settings,
          AppStrings.getString('addCommunityServices', currentLocale),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SuperAdminCommunityServicesScreen(),
              ),
            );
          },
        ),
        _buildActionButton(
          Icons.feedback,
          AppStrings.getString('usersLocation', currentLocale),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserLocationScreen(),
              ),
            );
          },
        ),
        _buildActionButton(
          Icons.speaker,
          AppStrings.getString('bayanList', currentLocale),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SuperAdminBayanManagementScreen(),
              ),
            );
          },
        ),
        _buildActionButton(
          Icons.settings,
          AppStrings.getString('appSetting', currentLocale),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppSettingView()),
            );
          },
        ),
        _buildActionButton(
          Icons.supervised_user_circle_rounded,
          AppStrings.getString('Super Admins', currentLocale),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SuperAdminsListScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: AppColors.mainColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingHadiyaRequests(
      PendingHadiyaProvider provider,
      String currentLocale,
      ) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.mainColor),
      );
    }

    if (provider.pendingHadiyaList.isEmpty) {
      return _buildEmptyState(
        AppStrings.getString('noPendingHadiyaRequests', currentLocale),
        currentLocale,
      );
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.pendingHadiyaList.length,
        separatorBuilder:
            (context, index) => Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final request = provider.pendingHadiyaList[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => HadiyaRequestDetailScreen(request: request),
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.mainColor,
                child: Icon(
                  Icons.account_balance,
                  color: AppColors.whiteBackground,
                ),
              ),
              title: Text(
                request.type,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                "${AppStrings.getString('from', currentLocale)}: ${request.masjidName}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: AppColors.mainColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count, String currentLocale) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mainColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.mainColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPendingRequests(String currentLocale) {
    return Consumer<PendingAdminImamListProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.mainColor),
          );
        }

        if (provider.unregisteredUsers.isEmpty) {
          return _buildEmptyState(
            AppStrings.getString('noPendingAdminRequests', currentLocale),
            currentLocale,
          );
        }

        return Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.unregisteredUsers.length,
            separatorBuilder:
                (context, index) => Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final request = provider.unregisteredUsers[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                          AdminRequestDetailScreen(request: request),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.mainColor,
                    child: Icon(
                      Icons.person_add,
                      color: AppColors.whiteBackground,
                    ),
                  ),
                  title: Text(
                    request.masjidName,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    request.email,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.mainColor,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSalahAlerts(String currentLocale) {
    final provider = context.watch<PendingAdminImamListProvider>();
    final requests = provider.requests;

    if (requests.isEmpty) {
      return _buildEmptyState(
        AppStrings.getString('noSalahClockAlerts', currentLocale),
        currentLocale,
      );
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: requests.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final alert = requests[index];

          final daysDiff = DateTime.now().difference(alert.timestamp).inDays;

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SalahClockScreen(),
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.mainColor,
                child: Icon(
                  Icons.access_time,
                  color: AppColors.whiteBackground,
                ),
              ),

              // mosqueName from Firestore
              title: Text(
                alert.mosqueName,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),

              // “x days since last update”
              subtitle: Text(
                "$daysDiff ${AppStrings.getString('daysSinceLastUpdate', currentLocale)}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.mainColor,
                ),
              ),

              // Refresh icon (you handle later)
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.mainColor),
                onPressed: () {
                  // optional refresh logic
                },
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildStatisticsGrid(String currentLocale) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${AppStrings.getString('error', currentLocale)}: ${snapshot.error}',
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  AppStrings.getString('noUsersFound', currentLocale),
                ),
              );
            }
            return _buildStatCard(
              AppStrings.getString('totalUsers', currentLocale),
              snapshot.data!.docs.length.toString(),
              Icons.people,
              currentLocale,
            );
          },
        ),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('subAdmin',).where('successfullyRegistered',isEqualTo: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${AppStrings.getString('error', currentLocale)}: ${snapshot.error}',
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  AppStrings.getString('noUsersFound', currentLocale),
                ),
              );
            }
            return  _buildStatCard(
              AppStrings.getString('totalAdmin', currentLocale),
              snapshot.data!.docs.length.toString(),
              Icons.today,
              currentLocale,
            );
          },
        ),
        // _buildStatCard(
        //   AppStrings.getString('bookings', currentLocale),
        //   "87",
        //   Icons.airplane_ticket,
        //   currentLocale,
        // ),
      ],
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      String currentLocale,
      ) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: AppColors.mainColor),
                  ),
                ),
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.mainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, String currentLocale) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.grey[500]),
        ),
      ),
    );
  }
}

class SalahAlert {
  final String masjid;
  final int days;

  SalahAlert({required this.masjid, required this.days});
}






// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:rafahiyatourism/const/color.dart';
// import 'package:rafahiyatourism/provider/locale_provider.dart';
// import 'package:rafahiyatourism/utils/language/app_strings.dart';
// import 'package:rafahiyatourism/view/super_admin_code/superadminhome/app_setting_screens/app_setting_view.dart';
// import 'package:rafahiyatourism/view/super_admin_code/superadminhome/general_announcement.dart';
// import 'package:rafahiyatourism/view/super_admin_code/superadminhome/all_admins.dart';
// import 'package:rafahiyatourism/view/super_admin_code/superadminhome/salah_clock_super_admin_screen.dart';
// import 'package:rafahiyatourism/view/super_admin_code/superadminhome/super_admin_list.dart';
// import 'package:rafahiyatourism/view/super_admin_code/superadminhome/tutorial_video_list.dart';
// import 'package:rafahiyatourism/view/super_admin_code/superadminhome/user_location/user_location.dart';
//
// import '../superadminprovider/pending_admin_imam_list.dart';
// import '../superadminprovider/pending_hadiyah_provider/pending_hadiyah_provider.dart';
// import 'add_community_service/add_community_services_super_admin.dart';
// import 'add_packages_screen.dart';
// import 'add_super_admin_screen.dart';
// import 'admin_request_detail_screen.dart';
// import 'bayan_screen.dart';
// import 'date_setting_screen.dart';
// import 'global_ads_screen.dart';
// import 'hadiyah/handiyah_request_detail_screen.dart';
//
// class SuperAdminHome extends StatefulWidget {
//   const SuperAdminHome({super.key});
//
//   @override
//   State<SuperAdminHome> createState() => _SuperAdminHomeState();
// }
//
// class _SuperAdminHomeState extends State<SuperAdminHome> {
//   final List<SalahAlert> salahAlerts = [
//     SalahAlert(masjid: "Masjid Al-Haram", days: 8),
//     SalahAlert(masjid: "Masjid An-Nabawi", days: 9),
//   ];
//
//   String _getCurrentLocale(BuildContext context) {
//     final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
//     return localeProvider.locale?.languageCode ?? 'en';
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final adminProvider = Provider.of<PendingAdminImamListProvider>(
//         context,
//         listen: false,
//       );
//       adminProvider.startListening();
//
//       final hadiyaProvider = Provider.of<PendingHadiyaProvider>(
//         context,
//         listen: false,
//       );
//       hadiyaProvider.startListening();
//     });
//   }
//
//   @override
//   void dispose() {
//     Provider.of<PendingAdminImamListProvider>(
//       context,
//       listen: false,
//     ).stopListening();
//     Provider.of<PendingHadiyaProvider>(context, listen: false).stopListening();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentLocale = _getCurrentLocale(context);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           AppStrings.getString('dashboard', currentLocale),
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: AppColors.mainColor,
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const AddSuperAdminScreen(),
//                 ),
//               );
//             },
//             icon: const Icon(
//               CupertinoIcons.person_add_solid,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildWelcomeCard(currentLocale),
//             const SizedBox(height: 24),
//
//             _buildQuickActions(currentLocale),
//             const SizedBox(height: 24),
//             Consumer<PendingAdminImamListProvider>(
//               builder: (context, pendingRequestProvider, child) {
//                 return _buildSectionTitle(
//                   AppStrings.getString('pendingAdminRequests', currentLocale),
//                   pendingRequestProvider.unregisteredUsers.length,
//                   currentLocale,
//                 );
//               },
//             ),
//
//             const SizedBox(height: 8),
//             _buildPendingRequests(currentLocale),
//             const SizedBox(height: 24),
//             Consumer<PendingHadiyaProvider>(
//               builder: (context, hadiyaProvider, child) {
//                 return Column(
//                   children: [
//                     _buildSectionTitle(
//                       AppStrings.getString(
//                         'pendingHadiyaRequests',
//                         currentLocale,
//                       ),
//                       hadiyaProvider.pendingHadiyaList.length,
//                       currentLocale,
//                     ),
//                     const SizedBox(height: 8),
//                     _buildPendingHadiyaRequests(hadiyaProvider, currentLocale),
//                   ],
//                 );
//               },
//             ),
//             const SizedBox(height: 24),
//             _buildSectionTitle(
//               AppStrings.getString('salahClockAlerts', currentLocale),
//               salahAlerts.length,
//               currentLocale,
//             ),
//             const SizedBox(height: 8),
//             _buildSalahAlerts(currentLocale),
//             const SizedBox(height: 24),
//             _buildSectionTitle(
//               AppStrings.getString('applicationStatistics', currentLocale),
//               0,
//               currentLocale,
//             ),
//             const SizedBox(height: 8),
//             _buildStatisticsGrid(currentLocale),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildWelcomeCard(String currentLocale) {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//
//     return StreamBuilder<DocumentSnapshot>(
//       stream:
//       userId != null
//           ? FirebaseFirestore.instance
//           .collection('super_admins')
//           .doc(userId)
//           .snapshots()
//           : null,
//       builder: (context, snapshot) {
//         final name =
//             snapshot.data?['name'] as String? ??
//                 AppStrings.getString('superAdmin', currentLocale);
//         print('Name of Super $name');
//         final email =
//             snapshot.data?['email'] as String? ??
//                 AppStrings.getString('superAdmin', currentLocale);
//         // final lastLogin = snapshot.data?['lastLogin'] as Timestamp?;
//
//         // String lastLoginText = AppStrings.getString(
//         //   'lastLoginNever',
//         //   currentLocale,
//         // );
//         // if (lastLogin != null) {
//         //   final formattedDate = DateFormat(
//         //     'MMM d, y - h:mm a',
//         //   ).format(lastLogin.toDate());
//         //   lastLoginText =
//         //       '${AppStrings.getString('lastLogin', currentLocale)}: $formattedDate';
//         // }
//
//         return Card(
//           color: Colors.white,
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 const CircleAvatar(
//                   radius: 30,
//                   backgroundColor: AppColors.mainColor,
//                   child: Icon(Icons.person, size: 30, color: Colors.white),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "${AppStrings.getString('welcome', currentLocale)}, $name",
//                         style: GoogleFonts.poppins(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.mainColor,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         email,
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildQuickActions(String currentLocale) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 3,
//       childAspectRatio: 0.9,
//       mainAxisSpacing: 8,
//       crossAxisSpacing: 8,
//       children: [
//         _buildActionButton(
//           Icons.people,
//           AppStrings.getString('admins', currentLocale),
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const AllAdminsScreen()),
//             );
//           },
//         ),
//
//         _buildActionButton(
//           Icons.access_time,
//           AppStrings.getString('salahClock', currentLocale),
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const SalahClockScreen()),
//             );
//           },
//         ),
//         _buildActionButton(
//           Icons.date_range,
//           AppStrings.getString('dateSettings', currentLocale),
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const DateSettingsScreen(),
//               ),
//             );
//           },
//         ),
//         _buildActionButton(
//           Icons.ads_click,
//           AppStrings.getString('globalAds', currentLocale),
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const GlobalAdsScreen()),
//             );
//           },
//         ),
//         _buildActionButton(
//           Icons.video_collection,
//           AppStrings.getString('uploadTutorials', currentLocale),
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const TutorialVideosListScreen(),
//               ),
//             );
//           },
//         ),
//         _buildActionButton(
//           Icons.tour,
//           AppStrings.getString('packages', currentLocale),
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const AddPackagesScreen(),
//               ),
//             );
//           },
//         ),
//         _buildActionButton(
//           Icons.announcement,
//           AppStrings.getString('generalAnnouncements', currentLocale),
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const GeneralAnnouncementScreen(),
//               ),
//             );
//           },
//         ),
//         _buildActionButton(
//           CupertinoIcons.settings,
//           AppStrings.getString('addCommunityServices', currentLocale),
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const SuperAdminCommunityServicesScreen(),
//               ),
//             );
//           },
//         ),
//         _buildActionButton(
//           Icons.feedback,
//           AppStrings.getString('usersLocation', currentLocale),
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const UserLocationScreen(),
//               ),
//             );
//           },
//         ),
//         _buildActionButton(
//           Icons.speaker,
//           AppStrings.getString('bayanList', currentLocale),
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const SuperAdminBayanManagementScreen(),
//               ),
//             );
//           },
//         ),
//         _buildActionButton(
//           Icons.settings,
//           AppStrings.getString('appSetting', currentLocale),
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const AppSettingView()),
//             );
//           },
//         ),
//         _buildActionButton(
//           Icons.supervised_user_circle_rounded,
//           AppStrings.getString('Super Admins', currentLocale),
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const SuperAdminsListScreen(),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.3),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 28, color: AppColors.mainColor),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPendingHadiyaRequests(
//       PendingHadiyaProvider provider,
//       String currentLocale,
//       ) {
//     if (provider.isLoading) {
//       return Center(
//         child: CircularProgressIndicator(color: AppColors.mainColor),
//       );
//     }
//
//     if (provider.pendingHadiyaList.isEmpty) {
//       return _buildEmptyState(
//         AppStrings.getString('noPendingHadiyaRequests', currentLocale),
//         currentLocale,
//       );
//     }
//
//     return Card(
//       color: Colors.white,
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListView.separated(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: provider.pendingHadiyaList.length,
//         separatorBuilder:
//             (context, index) => Divider(height: 1, color: Colors.grey[200]),
//         itemBuilder: (context, index) {
//           final request = provider.pendingHadiyaList[index];
//           return InkWell(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder:
//                       (context) => HadiyaRequestDetailScreen(request: request),
//                 ),
//               );
//             },
//             child: ListTile(
//               leading: CircleAvatar(
//                 backgroundColor: AppColors.mainColor,
//                 child: Icon(
//                   Icons.account_balance,
//                   color: AppColors.whiteBackground,
//                 ),
//               ),
//               title: Text(
//                 request.type,
//                 style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//               ),
//               subtitle: Text(
//                 "${AppStrings.getString('from', currentLocale)}: ${request.masjidName}",
//                 style: GoogleFonts.poppins(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               trailing: Icon(Icons.chevron_right, color: AppColors.mainColor),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title, int count, String currentLocale) {
//     return Row(
//       children: [
//         Text(
//           title,
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const Spacer(),
//         if (count > 0)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: AppColors.mainColor.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               count.toString(),
//               style: GoogleFonts.poppins(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.mainColor,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildPendingRequests(String currentLocale) {
//     return Consumer<PendingAdminImamListProvider>(
//       builder: (context, provider, child) {
//         if (provider.isLoading) {
//           return Center(
//             child: CircularProgressIndicator(color: AppColors.mainColor),
//           );
//         }
//
//         if (provider.unregisteredUsers.isEmpty) {
//           return _buildEmptyState(
//             AppStrings.getString('noPendingAdminRequests', currentLocale),
//             currentLocale,
//           );
//         }
//
//         return Card(
//           color: Colors.white,
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: provider.unregisteredUsers.length,
//             separatorBuilder:
//                 (context, index) => Divider(height: 1, color: Colors.grey[200]),
//             itemBuilder: (context, index) {
//               final request = provider.unregisteredUsers[index];
//               return InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder:
//                           (context) =>
//                           AdminRequestDetailScreen(request: request),
//                     ),
//                   );
//                 },
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: AppColors.mainColor,
//                     child: Icon(
//                       Icons.person_add,
//                       color: AppColors.whiteBackground,
//                     ),
//                   ),
//                   title: Text(
//                     request.masjidName,
//                     style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//                   ),
//                   subtitle: Text(
//                     request.email,
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   trailing: Icon(
//                     Icons.chevron_right,
//                     color: AppColors.mainColor,
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSalahAlerts(String currentLocale) {
//     if (salahAlerts.isEmpty) {
//       return _buildEmptyState(
//         AppStrings.getString('noSalahClockAlerts', currentLocale),
//         currentLocale,
//       );
//     }
//
//     return Card(
//       color: Colors.white,
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListView.separated(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: salahAlerts.length,
//         separatorBuilder:
//             (context, index) => Divider(height: 1, color: Colors.grey[200]),
//         itemBuilder: (context, index) {
//           final alert = salahAlerts[index];
//           return InkWell(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const SalahClockScreen(),
//                 ),
//               );
//             },
//             child: ListTile(
//               leading: CircleAvatar(
//                 backgroundColor: AppColors.mainColor,
//                 child: Icon(
//                   Icons.access_time,
//                   color: AppColors.whiteBackground,
//                 ),
//               ),
//               title: Text(
//                 alert.masjid,
//                 style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//               ),
//               subtitle: Text(
//                 "${alert.days} ${AppStrings.getString('daysSinceLastUpdate', currentLocale)}",
//                 style: GoogleFonts.poppins(
//                   fontSize: 12,
//                   color: AppColors.mainColor,
//                 ),
//               ),
//               trailing: IconButton(
//                 icon: const Icon(Icons.refresh, color: AppColors.mainColor),
//                 onPressed: () {
//                   // Handle refresh action
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildStatisticsGrid(String currentLocale) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       childAspectRatio: 1.3,
//       mainAxisSpacing: 12,
//       crossAxisSpacing: 12,
//       children: [
//         StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance.collection('users').snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Center(
//                 child: Text(
//                   '${AppStrings.getString('error', currentLocale)}: ${snapshot.error}',
//                 ),
//               );
//             }
//
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Text(
//                   AppStrings.getString('noUsersFound', currentLocale),
//                 ),
//               );
//             }
//             return _buildStatCard(
//               AppStrings.getString('totalUsers', currentLocale),
//               snapshot.data!.docs.length.toString(),
//               Icons.people,
//               currentLocale,
//             );
//           },
//         ),
//
//         StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance.collection('subAdmin',).where('successfullyRegistered',isEqualTo: true).snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Center(
//                 child: Text(
//                   '${AppStrings.getString('error', currentLocale)}: ${snapshot.error}',
//                 ),
//               );
//             }
//
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Text(
//                   AppStrings.getString('noUsersFound', currentLocale),
//                 ),
//               );
//             }
//             return  _buildStatCard(
//               AppStrings.getString('totalAdmin', currentLocale),
//               snapshot.data!.docs.length.toString(),
//               Icons.today,
//               currentLocale,
//             );
//           },
//         ),
//         // _buildStatCard(
//         //   AppStrings.getString('bookings', currentLocale),
//         //   "87",
//         //   Icons.airplane_ticket,
//         //   currentLocale,
//         // ),
//       ],
//     );
//   }
//
//   Widget _buildStatCard(
//       String title,
//       String value,
//       IconData icon,
//       String currentLocale,
//       ) {
//     return Card(
//       color: Colors.white,
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: AppColors.mainColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(icon, size: 18, color: AppColors.mainColor),
//                   ),
//                 ),
//                 Flexible(
//                   child: Text(
//                     title,
//                     style: GoogleFonts.poppins(
//                       fontSize: 11,
//                       color: Colors.grey[600],
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               value,
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.mainColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(String message, String currentLocale) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 24),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Center(
//         child: Text(
//           message,
//           style: GoogleFonts.poppins(color: Colors.grey[500]),
//         ),
//       ),
//     );
//   }
// }
//
// class SalahAlert {
//   final String masjid;
//   final int days;
//
//   SalahAlert({required this.masjid, required this.days});
// }
