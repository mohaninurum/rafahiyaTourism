// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:rafahiyatourism/const/color.dart';
//
// class PrayerTimesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     int selectedIndex = getSelectedPrayerIndex();
//     Map<String, String> prayerTimesDisplay = getPrayerTimesDisplay(selectedIndex);
//
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // First Row with Azan times and prayer indicators
//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   return Row(
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           prayerText('Azan: ${prayerTimesDisplay['azan']}'),
//                           prayerText('Jamat: ${prayerTimesDisplay['jamat']}'),
//                           prayerText('Awal: ${prayerTimesDisplay['awal']}'),
//                           prayerText('Akhir: ${prayerTimesDisplay['akhir']}'),
//                         ],
//                       ),
//                       Spacer(),
//                       ConstrainedBox(
//                         constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.7),
//                         child: Column(
//                           children: [
//                             SingleChildScrollView(
//                               scrollDirection: Axis.horizontal,
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: List.generate(5, (index) {
//                                   return Column(
//                                     children: [
//                                       prayerText(
//                                           ['Fajr', 'Zohar', 'Asar', 'Magrib', 'Isha'][index],
//                                           isBold: true
//                                       ),
//                                       SizedBox(height: 4),
//                                       Container(
//                                         width: 40,
//                                         height: 60,
//                                         decoration: BoxDecoration(
//                                           color: index == selectedIndex ? AppColors.mainColor : Colors.grey[300],
//                                           borderRadius: BorderRadius.circular(10),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 }),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//
//               SizedBox(height: 16),
//               // Friday and Eid prayer section
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   prayerText('Jumma/Friday Prayer', isBold: true),
//                   prayerText('Eid namaz', isBold: true),
//                 ],
//               ),
//               SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   prayerText('Jamat 1'),
//                   prayerText('Jamat 2'),
//                   prayerText('Jamat 1'),
//                   prayerText('Jamat 2'),
//                 ],
//               ),
//               SizedBox(height: 16),
//               // Additional prayer times section
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       prayerText('Azan time'),
//                       prayerText('Jamat time'),
//                       prayerText('Sunrise'),
//                     ],
//                   ),
//                   SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         SizedBox(
//                           width: 15,
//                         ),
//                         prayerText('Zawal'),
//                         SizedBox(
//                           width: 15,
//                         ),
//                         prayerText('Gurub'),
//                         SizedBox(
//                           width: 15,
//                         ),
//                         prayerText('Sehri'),
//                         SizedBox(
//                           width: 15,
//                         ),
//                         prayerText('Iftar'),
//
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//
//               SizedBox(height: 16),
//               // Announcements section
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   prayerText('Hadiya for Maulana'),
//                   prayerText('Hadiya for Masjid'),
//                   SizedBox(height: 16),
//                   prayerText('Announcement', isBold: true),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget prayerText(String text, {bool isBold = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 8),
//       child: Text(
//         text,
//         style: GoogleFonts.poppins(
//           fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           color: Colors.brown,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }
//
//   List<Widget> buildPrayerIndicators(int selectedIndex) {
//     return List.generate(5, (index) {
//       return Padding(
//         padding: EdgeInsets.symmetric(horizontal: 8),
//         child: Container(
//           width: 40,
//           height: 60,
//           decoration: BoxDecoration(
//             color: index == selectedIndex ? AppColors.mainColor : Colors.grey[300],
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     });
//   }
//
//   int getSelectedPrayerIndex() {
//     DateTime now = DateTime.now();
//
//     List<Map<String, dynamic>> prayerTimes = [
//       {'name': 'Fajr', 'hour': 5, 'minute': 0},
//       {'name': 'Zohar', 'hour': 13, 'minute': 0},
//       {'name': 'Asar', 'hour': 16, 'minute': 0},
//       {'name': 'Magrib', 'hour': 18, 'minute': 30},
//       {'name': 'Isha', 'hour': 20, 'minute': 30},
//     ];
//
//     int selectedIndex = 0;
//     for (int i = 0; i < prayerTimes.length; i++) {
//       int hour = prayerTimes[i]['hour'];
//       int minute = prayerTimes[i]['minute'];
//       if (now.hour > hour || (now.hour == hour && now.minute >= minute)) {
//         selectedIndex = i;
//       }
//     }
//
//     // If the current time is before Fajr, select Isha as the last missed prayer.
//     if (now.hour < prayerTimes[0]['hour']) {
//       return prayerTimes.length - 1; // Select Isha
//     }
//
//     return selectedIndex;
//   }
//
//   Map<String, String> getPrayerTimesDisplay(int selectedIndex)
//   {
//     List<Map<String, dynamic>> prayerTimes = [
//       {'name': 'Fajr', 'hour': 5, 'minute': 0},
//       {'name': 'Zohar', 'hour': 13, 'minute': 0},
//       {'name': 'Asar', 'hour': 16, 'minute': 0},
//       {'name': 'Magrib', 'hour': 18, 'minute': 30},
//       {'name': 'Isha', 'hour': 20, 'minute': 30},
//     ];
//
//     int totalPrayers = prayerTimes.length;
//     int nextIndex = (selectedIndex + 1) % totalPrayers;
//
//     String formatTime(int hour, int minute) {
//       return DateFormat.jm().format(DateTime(0, 0, 0, hour, minute));
//     }
//
//     String azanTime = prayerTimes[selectedIndex]['name'];
//     String jamatTime = formatTime(prayerTimes[selectedIndex]['hour'] + 1, 0);
//     String awalTime = formatTime(prayerTimes[selectedIndex]['hour'], prayerTimes[selectedIndex]['minute']);
//     String akhirTime = formatTime(prayerTimes[nextIndex]['hour'], prayerTimes[nextIndex]['minute']);
//
//     return {
//       'azan': azanTime,
//       'jamat': jamatTime,
//       'awal': awalTime,
//       'akhir': akhirTime,
//     };
//   }
// }
