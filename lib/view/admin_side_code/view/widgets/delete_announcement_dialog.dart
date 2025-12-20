import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../const/color.dart';
import '../../data/subAdminProvider/bayan_provider.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String docId;

  const DeleteConfirmationDialog({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("Delete Announcement", style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.blackColor,
      ),),
      content: const Text("Are you sure you want to delete this?"),
      actions: [
        TextButton(
          child: Text("Cancel", style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          icon: Icon(Icons.delete_forever, size: 18, color: AppColors.whiteColor,),
          label: Text("Yes, Delete", style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ),),
          onPressed: () {
            Provider.of<BayanProvider>(
              context,
              listen: false,
            ).deleteBayan(docId);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
