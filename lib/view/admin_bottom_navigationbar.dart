// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:rafahiyatourism/view/home/home_screen.dart';
// import 'package:rafahiyatourism/view/more_items/more_items_screen.dart';
// import 'package:rafahiyatourism/view/wallet/wallet_screen.dart';
// import 'package:responsive_navigation_bar/responsive_navigation_bar.dart';
//
// import '../const/color.dart';
//
// class BottomNavigation extends StatefulWidget {
//   const BottomNavigation({super.key});
//
//   @override
//   State<BottomNavigation> createState() =>
//       _BottomNavigationState();
// }
//
// class _BottomNavigationState extends State<BottomNavigation> {
//   int _selectedIndex = 0;
//
//   void changeTab(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   List<Widget> screens = [
//     HomeScreen(),
//     MoreItemsScreen(),
//     WalletScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor2,
//       body: screens[_selectedIndex],
//       bottomNavigationBar: ResponsiveNavigationBar(
//         selectedIndex: _selectedIndex,
//         onTabChange: changeTab,
//         // showActiveButtonText: false,
//         backgroundColor: AppColors.backgroundColor2,
//         inactiveIconColor: AppColors.blackBackground,
//         textStyle: GoogleFonts.poppins(
//           color: Colors.white,
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//         ),
//         navigationBarButtons: const <NavigationBarButton>[
//           NavigationBarButton(
//             text: 'Home',
//             icon: Icons.home_outlined,
//             backgroundColor: AppColors.backgroundColor2,
//             backgroundGradient: LinearGradient(
//               colors: [
//                 AppColors.mainColor,
//                 AppColors.backgroundColor2,
//                 AppColors.backgroundColor3,
//               ],
//             ),
//           ),
//           NavigationBarButton(
//             text: 'More Items',
//             icon: CupertinoIcons.archivebox_fill,
//             backgroundColor: AppColors.backgroundColor2,
//             backgroundGradient: LinearGradient(
//               colors: [
//                 AppColors.mainColor,
//                 AppColors.backgroundColor2,
//                 AppColors.backgroundColor3,
//               ],
//             ),
//           ),
//           NavigationBarButton(
//             text: 'Wallet',
//             icon: Icons.wallet,
//             backgroundColor: AppColors.backgroundColor2,
//             backgroundGradient: LinearGradient(
//               colors: [
//                 AppColors.mainColor,
//                 AppColors.backgroundColor2,
//                 AppColors.backgroundColor3,
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
