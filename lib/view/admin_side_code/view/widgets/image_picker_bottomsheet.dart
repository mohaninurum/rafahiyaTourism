import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';

import '../../data/subAdminProvider/admin_register_provider.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  const ImagePickerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminRegisterProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo, color: AppColors.mainColor),
            title: Text(
              "Pick from Gallery",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.blackColor,
              ),
            ),
            onTap: () => Navigator.pop(context, 'gallery'),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: AppColors.mainColor),
            title: Text(
              "Pick from Camera",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.blackColor,
              ),
            ),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
        ],
      ),
    );
  }
}
