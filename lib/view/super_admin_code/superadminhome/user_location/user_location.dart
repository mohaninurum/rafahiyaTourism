import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../const/color.dart';

class UserLocationScreen extends StatefulWidget {
  const UserLocationScreen({super.key});

  @override
  State<UserLocationScreen> createState() => _UserLocationScreenState();
}

class _UserLocationScreenState extends State<UserLocationScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: (){
            Navigator.of(context).pop();
          }, icon: Icon(Icons.arrow_back_ios_new_outlined,color: AppColors.whiteColor,)),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.mainColor,
          centerTitle: true,
          title: Text(
            "User Location",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Text("Coming Soon",style: GoogleFonts.poppins(),),
      ),
    );
  }
}























//
// class UserLocationScreen extends StatefulWidget {
//   const UserLocationScreen({super.key});
//
//   @override
//   State<UserLocationScreen> createState() => _UserLocationScreenState();
// }
//
// class _UserLocationScreenState extends State<UserLocationScreen> {
//   final List<FeedbackModel> _feedbacks = [];
//   final List<String> _filterOptions = ['All', 'Bug Report', 'Feature Request', 'Complaint', 'Suggestion'];
//   String _selectedFilter = 'All';
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFeedbacks();
//   }
//
//   // Simulate loading feedback from Firebase
//   Future<void> _loadFeedbacks() async {
//     await Future.delayed(const Duration(seconds: 2));
//
//     setState(() {
//       _feedbacks.addAll([
//         FeedbackModel(
//           id: '1',
//           userName: 'Ahmed Khan',
//           userEmail: 'ahmed@example.com',
//           message: 'The prayer times are not updating correctly in my area. Please fix this issue.',
//           type: 'Bug Report',
//           rating: 3,
//           date: DateTime.now().subtract(const Duration(days: 2)),
//           masjidName: 'Central Masjid',
//           status: 'Pending',
//         ),
//         FeedbackModel(
//           id: '2',
//           userName: 'Fatima Ahmed',
//           userEmail: 'fatima@example.com',
//           message: 'It would be great to have a feature to set reminders for Zakat payment.',
//           type: 'Feature Request',
//           rating: 5,
//           date: DateTime.now().subtract(const Duration(days: 5)),
//           masjidName: 'Not specified',
//           status: 'Reviewed',
//         ),
//         FeedbackModel(
//           id: '3',
//           userName: 'Mohammed Ali',
//           userEmail: 'm.ali@example.com',
//           message: 'The Qibla direction seems inaccurate in the app. Please check the calibration.',
//           type: 'Complaint',
//           rating: 2,
//           date: DateTime.now().subtract(const Duration(days: 7)),
//           masjidName: 'Al-Madinah Masjid',
//           status: 'In Progress',
//         ),
//         FeedbackModel(
//           id: '4',
//           userName: 'Aisha Rahman',
//           userEmail: 'aisha.r@example.com',
//           message: 'Please add more tutorial videos for beginners learning how to pray.',
//           type: 'Suggestion',
//           rating: 4,
//           date: DateTime.now().subtract(const Duration(days: 10)),
//           masjidName: 'Not specified',
//           status: 'Completed',
//         ),
//         FeedbackModel(
//           id: '5',
//           userName: 'Omar Hassan',
//           userEmail: 'omar.h@example.com',
//           message: 'The app crashes when I try to use the Tasbih counter multiple times.',
//           type: 'Bug Report',
//           rating: 1,
//           date: DateTime.now().subtract(const Duration(days: 12)),
//           masjidName: 'Islamic Center',
//           status: 'Pending',
//         ),
//       ]);
//       _isLoading = false;
//     });
//   }
//
//   void _showFeedbackDetails(FeedbackModel feedback) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Feedback Details',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.mainColor,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(feedback.status),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       feedback.status,
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(Icons.person, color: AppColors.mainColor),
//                 title: Text(
//                   feedback.userName,
//                   style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//                 ),
//                 subtitle: Text(feedback.userEmail),
//               ),
//               if (feedback.masjidName != 'Not specified')
//                 ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   leading: const Icon(Icons.mosque, color: AppColors.mainColor),
//                   title: Text(
//                     'Masjid: ${feedback.masjidName}',
//                     style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//                   ),
//                 ),
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(Icons.category, color: AppColors.mainColor),
//                 title: Text(
//                   'Type: ${feedback.type}',
//                   style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//                 ),
//               ),
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(Icons.star, color: AppColors.mainColor),
//                 title: Text(
//                   'Rating: ${feedback.rating}/5',
//                   style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//                 ),
//                 subtitle: Row(
//                   children: List.generate(5, (index) {
//                     return Icon(
//                       index < feedback.rating ? Icons.star : Icons.star_border,
//                       color: Colors.amber,
//                       size: 20,
//                     );
//                   }),
//                 ),
//               ),
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(Icons.calendar_today, color: AppColors.mainColor),
//                 title: Text(
//                   'Date: ${DateFormat('MMM dd, yyyy').format(feedback.date)}',
//                   style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Message:',
//                 style: GoogleFonts.poppins(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   feedback.message,
//                   style: GoogleFonts.poppins(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: Text(
//                         'Close',
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Handle update status
//                         Navigator.pop(context);
//                         _showStatusUpdateDialog(feedback);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.mainColor,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: Text(
//                         'Update Status',
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _showStatusUpdateDialog(FeedbackModel feedback) {
//     final List<String> statusOptions = ['Pending', 'Reviewed', 'In Progress', 'Completed'];
//     String selectedStatus = feedback.status;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             'Update Feedback Status',
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.w600,
//               color: AppColors.mainColor,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Change status for feedback from ${feedback.userName}',
//                 style: GoogleFonts.poppins(),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField(
//                 value: selectedStatus,
//                 items: statusOptions.map((String status) {
//                   return DropdownMenuItem(
//                     value: status,
//                     child: Text(status),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   selectedStatus = value!;
//                 },
//                 decoration: InputDecoration(
//                   labelText: 'Status',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.poppins(),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Update status logic would go here
//                 setState(() {
//                   feedback.status = selectedStatus;
//                 });
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       'Status updated to $selectedStatus',
//                       style: GoogleFonts.poppins(),
//                     ),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.mainColor,
//               ),
//               child: Text(
//                 'Update',
//                 style: GoogleFonts.poppins(color: Colors.white),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'Pending':
//         return Colors.orange;
//       case 'Reviewed':
//         return Colors.blue;
//       case 'In Progress':
//         return Colors.purple;
//       case 'Completed':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   IconData _getFeedbackIcon(String type) {
//     switch (type) {
//       case 'Bug Report':
//         return Icons.bug_report;
//       case 'Feature Request':
//         return Icons.lightbulb_outline;
//       case 'Complaint':
//         return Icons.warning;
//       case 'Suggestion':
//         return Icons.thumb_up;
//       default:
//         return Icons.feedback;
//     }
//   }
//
//   List<FeedbackModel> get _filteredFeedbacks {
//     if (_selectedFilter == 'All') {
//       return _feedbacks;
//     }
//     return _feedbacks.where((feedback) => feedback.type == _selectedFilter).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           'User Feedback',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: AppColors.mainColor,
//         centerTitle: true,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(CupertinoIcons.back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: SizedBox(
//               height: 40,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: _filterOptions.length,
//                 itemBuilder: (context, index) {
//                   final option = _filterOptions[index];
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: FilterChip(
//                       label: Text(option),
//                       selected: _selectedFilter == option,
//                       onSelected: (selected) {
//                         setState(() {
//                           _selectedFilter = selected ? option : 'All';
//                         });
//                       },
//                       backgroundColor: Colors.grey[200],
//                       selectedColor: AppColors.mainColor,
//                       labelStyle: GoogleFonts.poppins(
//                         color: _selectedFilter == option ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _filteredFeedbacks.isEmpty
//                 ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.feedback,
//                     size: 60,
//                     color: Colors.grey[300],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No feedback found',
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//                 : ListView.builder(
//               padding: const EdgeInsets.only(bottom: 16),
//               itemCount: _filteredFeedbacks.length,
//               itemBuilder: (context, index) {
//                 final feedback = _filteredFeedbacks[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ListTile(
//                     onTap: () => _showFeedbackDetails(feedback),
//                     leading: Icon(
//                       _getFeedbackIcon(feedback.type),
//                       color: AppColors.mainColor,
//                       size: 28,
//                     ),
//                     title: Text(
//                       feedback.userName,
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     subtitle: Text(
//                       feedback.message.length > 50
//                           ? '${feedback.message.substring(0, 50)}...'
//                           : feedback.message,
//                       style: GoogleFonts.poppins(),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     trailing: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           DateFormat('MMM dd').format(feedback.date),
//                           style: GoogleFonts.poppins(
//                             fontSize: 12,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: List.generate(5, (i) {
//                             return Icon(
//                               i < feedback.rating ? Icons.star : Icons.star_border,
//                               color: Colors.amber,
//                               size: 16,
//                             );
//                           }),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class FeedbackModel {
//   final String id;
//   final String userName;
//   final String userEmail;
//   final String message;
//   final String type;
//   final int rating;
//   final DateTime date;
//   final String masjidName;
//   String status;
//
//   FeedbackModel({
//     required this.id,
//     required this.userName,
//     required this.userEmail,
//     required this.message,
//     required this.type,
//     required this.rating,
//     required this.date,
//     required this.masjidName,
//     required this.status,
//   });
// }