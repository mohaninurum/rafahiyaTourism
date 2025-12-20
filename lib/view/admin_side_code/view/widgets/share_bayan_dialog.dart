import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import '../../data/subAdminProvider/bayan_provider.dart';
import '../../data/utils/circular_indicator_spinkit.dart';

class ShareBayanDialog extends StatefulWidget {
  const ShareBayanDialog({super.key});

  @override
  State<ShareBayanDialog> createState() => _ShareBayanDialogState();
}

class _ShareBayanDialogState extends State<ShareBayanDialog> {
  final TextEditingController linkController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void dispose() {
    linkController.dispose();
    titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _showPickOptions(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: Text(AppStrings.getString('pickFromGallery', currentLocale)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: Text(AppStrings.getString('pickFromCamera', currentLocale)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final provider = Provider.of<BayanProvider>(context);

    return AlertDialog(
      backgroundColor: AppColors.whiteColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.all(16),
      title: Text(
        AppStrings.getString('shareAnnouncement', currentLocale),
        style: GoogleFonts.poppins(
          color: AppColors.mainColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 340,
        child: provider.isLoading
            ? const Center(
          child: CustomCircularProgressIndicator(
            size: 50,
            color: Colors.blue,
            spinKitType: SpinKitType.circle,
          ),
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: AppStrings.getString('titleOfAnnouncement', currentLocale),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: linkController,
                decoration: InputDecoration(
                  labelText: AppStrings.getString('enterVideoLink', currentLocale),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _showPickOptions(context),
                icon: const Icon(Icons.image),
                label: Text(AppStrings.getString('pickImage', currentLocale)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: provider.isLoading
          ? []
          : [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.getString('back', currentLocale),
            style: GoogleFonts.poppins(
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        MaterialButton(
          color: AppColors.mainColor,
          onPressed: () {
            if (titleController.text.trim().isEmpty ) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.getString('pleaseEnterTitle', currentLocale)),
                ),
              );
              return;
            }
            provider.shareBayan(
              context,
              titleController.text.trim(),
              linkController.text.trim(),
              _selectedImage,
            );
          },
          child: Text(
            AppStrings.getString('share', currentLocale),
            style: GoogleFonts.poppins(
              color: AppColors.whiteColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}