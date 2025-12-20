import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';


class TasbihHistoryScreen extends StatelessWidget {
  const TasbihHistoryScreen({super.key});

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(
          AppStrings.getString('tasbihHistory', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.mainColor),
      ),
      body: _buildSessionsTab(context, currentLocale),
    );
  }

  Widget _buildSessionsTab(BuildContext context, String currentLocale) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey.shade300),
            SizedBox(height: 16),
            Text(
              AppStrings.getString('signInToViewSessions', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: AppColors.mainColor));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    Icons.error_outline, size: 64, color: Colors.grey.shade300),
                SizedBox(height: 16),
                Text(
                  AppStrings.getString('errorLoadingSessions', currentLocale),
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                SizedBox(height: 16),
                Text(
                  AppStrings.getString('noSessionsYet', currentLocale),
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppStrings.getString(
                      'completeSessionToSeeHere', currentLocale),
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final sessions = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            final data = session.data() as Map<String, dynamic>;

            // Add null checks for all data fields
            final dikhrName = data['dikhr_name'] ??
                AppStrings.getString('unknownDikhr', currentLocale);
            final count = data['count'] ?? 0;
            final loops = data['loops'] ?? 0;
            final totalCount = data['total_count'] ?? count;
            final timestamp = data['timestamp'] as Timestamp?;

            return InkWell(
              onTap: () {
                // Return the session data when tapped
                Navigator.pop(context, {
                  'dikhr_name': dikhrName,
                  'dikhr_arabic': data['dikhr_arabic'] ?? dikhrName,
                  'count': count,
                  'loops': loops,
                  'total_count': totalCount,
                  'custom_target': data['custom_target'] ?? 33,
                  'timestamp': timestamp,
                });
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            dikhrName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          timestamp != null ? _formatTimestamp(
                              timestamp,) : AppStrings.getString(
                              'noDate', currentLocale),
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSessionDetail(AppStrings.getString(
                            'counts', currentLocale), "$count", currentLocale),
                        SizedBox(width: 16),
                        _buildSessionDetail(AppStrings.getString(
                            'loops', currentLocale), "$loops", currentLocale),
                        SizedBox(width: 16),
                        _buildSessionDetail(AppStrings.getString(
                            'total', currentLocale), "$totalCount",
                            currentLocale),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSessionDetail(String title, String value, String currentLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.mainColor,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMM d, yyyy - hh:mm a').format(date);
  }


}
