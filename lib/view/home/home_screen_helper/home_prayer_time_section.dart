// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:rafahiyatourism/const/color.dart';
//
// import '../../../provider/home_masjid_data_provider.dart';
//
// class PrayerTimesSection extends StatelessWidget {
//   final int tabIndex;
//
//   const PrayerTimesSection({super.key, required this.tabIndex});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HomeMasjidDataProvider>(
//       builder: (context, dataProvider, child) {
//         final prayerTimes = dataProvider.getPrayerTimes(tabIndex);
//
//         if (prayerTimes == null || prayerTimes.isEmpty) {
//           return Container(
//             margin: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // Header
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: AppColors.mainColor,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(12),
//                       topRight: Radius.circular(12),
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Daily Prayer Times',
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   child: Center(
//                     child: Text(
//                       'No prayer times available',
//                       style: GoogleFonts.poppins(
//                         color: AppColors.mainColor,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         // Define the order of prayers to display
//         final List<String> prayerOrder = [
//           'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Jumuah'
//         ];
//
//         return Container(
//           margin: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.mainColor,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Daily Prayer Times',
//                     style: GoogleFonts.poppins(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//
//               // Content
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     // Header Row (Salah, Azan, Jamat, Awal, Akhir)
//                     Row(
//                       children: [
//                         Container(
//                           width: 80,
//                           child: Text(
//                             'Salah',
//                             style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.left,
//                           ),
//                         ),
//                         Expanded(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Text('Azan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//                               Text(
//                                 'Jamat',
//                                 style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//                               ),
//                               Text('Awal', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//                               Text(
//                                 'Akhir',
//                                 style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Divider(),
//                     // Prayer Rows
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Vertical "Salah" column
//                         Container(
//                           width: 80,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: prayerOrder.map((prayerName) {
//                               return Container(
//                                 height: 40,
//                                 alignment: Alignment.centerLeft,
//                                 child: Text(
//                                   prayerName,
//                                   style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                         // Prayer times
//                         Expanded(
//                           child: Column(
//                             children: prayerOrder.map((prayerName) {
//                               final prayerData = prayerTimes[prayerName];
//                               final isJumuah = prayerName == 'Jumuah';
//
//                               final azaanTime = prayerData is Map
//                                   ? (prayerData['azaanTime'] ?? 'NA')
//                                   : 'NA';
//                               final jammatTime = prayerData is Map
//                                   ? (prayerData['jammatTime'] ?? 'NA')
//                                   : 'NA';
//                               final awalTime = 'NA'; // These seem to be hardcoded in your original UI
//                               final akhirTime = 'NA'; // These seem to be hardcoded in your original UI
//
//                               return Container(
//                                 height: 40,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                   children: [
//                                     Text(
//                                       isJumuah ? 'NA' : azaanTime,
//                                       style: GoogleFonts.poppins(
//                                         color: (isJumuah ? 'NA' : azaanTime) == 'NA'
//                                             ? Colors.grey
//                                             : Colors.black,
//                                       ),
//                                     ),
//                                     Text(
//                                       jammatTime,
//                                       style: GoogleFonts.poppins(
//                                         color: jammatTime == 'NA'
//                                             ? Colors.grey
//                                             : Colors.black,
//                                       ),
//                                     ),
//                                     Text(
//                                       awalTime,
//                                       style: GoogleFonts.poppins(
//                                         color: awalTime == 'NA'
//                                             ? Colors.grey
//                                             : Colors.black,
//                                       ),
//                                     ),
//                                     Text(
//                                       akhirTime,
//                                       style: GoogleFonts.poppins(
//                                         color: akhirTime == 'NA'
//                                             ? Colors.grey
//                                             : Colors.black,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }